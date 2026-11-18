#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
docx_page_images.py — Extract every *displayed* image from .docx exam files.

WHAT THIS DOES
--------------
Word exam documents (.docx) embed their pictures inside the zip package under
`word/media/` and reference them from `word/document.xml`. This script walks the
document body (paragraphs and tables, in order), finds every image that is
actually *shown* in the page, and writes each one out as:

    <page><letter>.png   in  <name>_png/    (always a REAL PNG)
    <page><letter>.webp  in  <name>_webp/   (always WebP)
    <name>_reporte.txt                     (counts, pages, failures)

Naming: 1a, 1b, ... 35c ...  The page number comes from Word's own page-break
markers (w:lastRenderedPageBreak or w:br[@w:type="page"]) so images can be
matched back to the exam's cases/questions.

SCOPE — WHY ONLY *DISPLAYED* IMAGES
-----------------------------------
We deliberately extract ONLY images referenced via `a:blip` (modern DrawingML)
and `v:imagedata` (legacy VML), which are the elements Word renders on the
page.

We do NOT chase `a:imgLayer`. Word stores a hidden "original" copy of some
pictures in an `imgLayer` extension (reltype `.../hdphoto`, codec JPEG-XR
`.wdp`). We verified across the 2026 and 2027 CMCOMF files that those hidden
copies are ALWAYS the SAME resolution as the displayed image — they are a
same-res JPEG-XR backup, not a higher-res original. Extracting them adds
duplicate files and zero quality, so they are out of scope. (This also means we
never need a JPEG-XR decoder here.)

FORMATS WE ACTUALLY HAVE TO HANDLE
----------------------------------
The displayed images come in a handful of real codecs regardless of extension:

    PNG  ......... copied as-is (already the target format)
    JPEG / TIFF / BMP / GIF / PSD
           ....... decoded with Pillow and re-encoded to PNG
    EMF / WMF .... vector metafiles; Pillow CANNOT decode these. We rasterize
                   them with LibreOffice headless (`soffice --convert-to png`),
                   which is the only decoder available on this machine
                   (ImageMagick here has no EMF delegate, no Inkscape).

USAGE
-----
    docx_page_images.py FILE.docx [FILE2.docx ...]
    docx_page_images.py DIRECTORY        # globs *.docx in that folder

Outputs are written next to each source .docx.
"""

import io
import os
import string
import subprocess
import sys
import tempfile

import docx
from docx.opc.constants import RELATIONSHIP_TYPE as RT
from docx.oxml.ns import nsmap
from docx.table import Table
from docx.text.paragraph import Paragraph
from PIL import Image

# Some exam scans are large; don't let Pillow abort on "decompression bombs".
Image.MAX_IMAGE_PIXELS = None

# Only the relationship type Word uses for images *rendered in the document*.
# (We intentionally exclude the hidden `.../hdphoto` originals; see docstring.)
IMAGE_REL_TYPES = {
    RT.IMAGE,  # http://schemas.openxmlformats.org/officeDocument/2006/relationships/image
}

# Older documents embed pictures through VML (`<v:imagedata r:id="...">`). The
# `v:` namespace prefix is not always declared in the maps python-docx merges,
# so we make sure it resolves before running our xpath.
nsmap["v"] = "urn:schemas-microsoft-com:vml"


# ---------------------------------------------------------------------------
# Format detection
# ---------------------------------------------------------------------------
def sniff(blob):
    """Return the TRUE format of an image blob from its magic bytes.

    We cannot trust the part's filename extension (Word sometimes mislabels),
    so we look at the leading bytes and fall back to asking Pillow.
    """
    if blob[:8] == b"\x89PNG\r\n\x1a\n":
        return "png"
    if blob[:3] == b"\xff\xd8\xff":
        return "jpeg"
    if blob[:4] in (b"II*\x00", b"MM\x00*"):
        return "tiff"
    if blob[:4] == b"GIF8":
        return "gif"
    if blob[:2] == b"BM":
        return "bmp"
    if blob[:4] == b"8BPS":
        return "psd"
    if blob[:4] == b"\x01\x00\x00\x00":
        return "emf"   # Enhanced Metafile (Word vector images)
    if blob[:4] == b"\xd7\xcd\xc6\x9a":
        return "wmf"   # Windows Metafile
    # JPEG-XR / HD Photo (.wdp) starts with II\xbc\x01 or MM\x01\xbc, but we
    # don't extract those (hidden same-res originals), so no branch needed.
    try:
        return (Image.open(io.BytesIO(blob)).format or "").lower()
    except Exception:
        return "unknown"


# ---------------------------------------------------------------------------
# Conversion helpers
# ---------------------------------------------------------------------------
def png_from_pil(im):
    """Serialize a Pillow image to PNG bytes, normalizing odd color modes.

    Some source modes (CMYK, 16-bit, etc.) either can't be saved as PNG
    directly or surprise downstream consumers, so we coerce to a sane mode.
    """
    if im.mode not in ("RGB", "RGBA", "L", "LA", "P", "I", "I;16"):
        im = im.convert("RGBA" if "A" in im.mode else "RGB")
    out = io.BytesIO()
    im.save(out, "PNG")
    return out.getvalue()


def convert_emf(blob, tmpdir, tag):
    """Rasterize an EMF/WMF blob to PNG bytes using LibreOffice headless.

    Pillow has no EMF/WMF decoder, so we shell out to `soffice`. A throwaway
    user-installation profile keeps this from locking against any running
    LibreOffice GUI instance. Returns PNG bytes.
    """
    src = os.path.join(tmpdir, f"{tag}.emf")
    with open(src, "wb") as f:
        f.write(blob)
    profile = os.path.join(tmpdir, f"lo_{tag}")
    subprocess.run(
        [
            "soffice",
            "--headless",
            "--norestore",
            "--nologo",
            f"-env:UserInstallation=file://{profile}",
            "--convert-to",
            "png",
            "--outdir",
            tmpdir,
            src,
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        timeout=180,
    )
    out = os.path.join(tmpdir, f"{tag}.png")
    with Image.open(out) as im:
        return png_from_pil(im)


def make_png(blob, fmt, tmpdir, tag):
    """Produce REAL PNG bytes for one image, whatever its source format.

    - PNG input is copied verbatim (keeps the original encoding/quality).
    - Raster formats Pillow can read are re-encoded losslessly to PNG.
    - EMF/WMF go through LibreOffice (vector -> raster).
    - Anything unrecognized gets one last Pillow attempt, else the raw blob
      (so we never lose data even if it's not a real PNG).
    """
    if fmt == "png":
        return blob
    if fmt in ("jpeg", "tiff", "bmp", "gif", "psd"):
        with Image.open(io.BytesIO(blob)) as im:
            return png_from_pil(im)
    if fmt in ("emf", "wmf"):
        return convert_emf(blob, tmpdir, tag)
    try:
        with Image.open(io.BytesIO(blob)) as im:
            return png_from_pil(im)
    except Exception:
        return blob


def make_webp(png_bytes):
    """Convert (already-correct) PNG bytes to WebP bytes.

    Converting from the normalized PNG guarantees the WebP matches the PNG
    content exactly. quality=90 trades a little size for near-lossless output.
    """
    with Image.open(io.BytesIO(png_bytes)) as im:
        if im.mode not in ("RGB", "RGBA", "L", "LA", "P"):
            im = im.convert("RGBA" if "A" in im.mode else "RGB")
        out = io.BytesIO()
        im.save(out, "WEBP", quality=90)
        return out.getvalue()


def get_letter(index):
    """0->a, 25->z, 26->aa, 27->ab ...  (image counter within a page)."""
    alphabet = string.ascii_lowercase
    if index < 26:
        return alphabet[index]
    return f"{alphabet[(index // 26) - 1]}{alphabet[index % 26]}"


# ---------------------------------------------------------------------------
# Document traversal
# ---------------------------------------------------------------------------
def iter_block_items(parent):
    """Yield paragraphs and tables of the body (or a table cell) in order.

    python-docx exposes paragraphs and tables separately; this generator keeps
    document order, which is what makes the page/letter naming meaningful.
    """
    if isinstance(parent, docx.document.Document):
        parent_elm = parent.element.body
    elif isinstance(parent, docx.table._Cell):
        parent_elm = parent._tc
    else:
        raise TypeError(f"Unknown parent type: {type(parent)}")

    for child in parent_elm.iterchildren():
        if isinstance(child, docx.oxml.text.paragraph.CT_P):
            yield Paragraph(child, parent)
        elif isinstance(child, docx.oxml.table.CT_Tbl):
            yield Table(child, parent)


def process_docx(file_name):
    """Extract all displayed images from one .docx into _png/, _webp/, report."""
    base_name = os.path.splitext(file_name)[0]
    png_dir = f"{base_name}_png"
    webp_dir = f"{base_name}_webp"
    os.makedirs(png_dir, exist_ok=True)
    os.makedirs(webp_dir, exist_ok=True)

    doc = docx.Document(file_name)
    # Map relationship id -> image part, but ONLY for images rendered on the
    # page (RT.IMAGE). This is the single place the "displayed-only" scope is
    # enforced; the xpath below also matches only a:blip / v:imagedata.
    image_map = {
        r.rId: r.target_part
        for r in doc.part.rels.values()
        if r.reltype in IMAGE_REL_TYPES
    }

    current_page = 1        # advances on each page-break marker
    images_on_page = 0      # resets per page; drives the a/b/c letter
    total = 0
    pages_with_images = set()
    fmt_counts = {}         # true-format histogram for the report
    failures = []           # (name, fmt, error) for anything that didn't save

    def process_paragraph(paragraph):
        nonlocal current_page, images_on_page, total

        # 1) Count page breaks BEFORE the images in this paragraph, so images
        #    that start a new page get the new page number.
        breaks = paragraph._element.xpath(
            './/w:lastRenderedPageBreak | .//w:br[@w:type="page"]'
        )
        if breaks:
            current_page += len(breaks)
            images_on_page = 0

        # 2) Grab every DISPLAYED image reference: modern (a:blip) and legacy
        #    VML (v:imagedata). imgLayer/hdphoto are intentionally not matched.
        img_rids = paragraph._element.xpath(
            ".//a:blip/@r:embed | .//v:imagedata/@r:id"
        )
        for rid in img_rids:
            if rid not in image_map:
                continue  # reference without an extractable image part
            blob = image_map[rid].blob
            fmt = sniff(blob)
            name = f"{current_page}{get_letter(images_on_page)}"
            try:
                with tempfile.TemporaryDirectory() as tmpdir:
                    png_bytes = make_png(blob, fmt, tmpdir, name)
                    webp_bytes = make_webp(png_bytes)
                with open(os.path.join(png_dir, f"{name}.png"), "wb") as f:
                    f.write(png_bytes)
                with open(os.path.join(webp_dir, f"{name}.webp"), "wb") as f:
                    f.write(webp_bytes)
            except Exception as e:
                # Keep going; record the failure instead of aborting the run.
                failures.append((name, fmt, str(e)))
                print(f"  ERROR {name} ({fmt}): {e}")
                images_on_page += 1
                continue

            fmt_counts[fmt] = fmt_counts.get(fmt, 0) + 1
            total += 1
            images_on_page += 1
            pages_with_images.add(current_page)
            print(f"  {name} (pag {current_page}, {fmt})")

    print(f"Procesando: {file_name}")
    # Walk the body in order; images inside table cells are included too.
    for block in iter_block_items(doc):
        if isinstance(block, Paragraph):
            process_paragraph(block)
        elif isinstance(block, Table):
            for row in block.rows:
                for cell in row.cells:
                    for paragraph in cell.paragraphs:
                        process_paragraph(paragraph)

    # Human-readable summary alongside the images.
    report_path = f"{base_name}_reporte.txt"
    with open(report_path, "w", encoding="utf-8") as rf:
        rf.write("Reporte de extraccion de imagenes\n")
        rf.write("=" * 40 + "\n")
        rf.write(f"Archivo original: {file_name}\n")
        rf.write(f"Total de imagenes: {total}\n")
        rf.write(f"Formatos: {fmt_counts}\n")
        rf.write(f"Paginas con imagenes: {sorted(pages_with_images)}\n")
        rf.write(f"Directorio PNG: {png_dir}\n")
        rf.write(f"Directorio WebP: {webp_dir}\n")
        if failures:
            rf.write(f"Fallos ({len(failures)}):\n")
            for name, fmt, err in failures:
                rf.write(f"  {name} ({fmt}): {err}\n")
        rf.write("=" * 40 + "\n")

    print(f"Finalizado: {total} imagenes, {len(failures)} fallos")
    print(f"Reporte: {report_path}")
    return total, failures


def collect_inputs(args):
    """Expand args into a list of .docx paths (dirs are globbed, non-recursive)."""
    files = []
    for arg in args:
        if os.path.isdir(arg):
            files.extend(
                os.path.join(arg, f)
                for f in sorted(os.listdir(arg))
                if f.lower().endswith(".docx") and not f.startswith("~$")
            )
        elif os.path.isfile(arg):
            files.append(arg)
        else:
            print(f"Aviso: no existe: {arg}", file=sys.stderr)
    return files


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    files = collect_inputs(sys.argv[1:])
    if not files:
        print("No se encontraron archivos .docx.", file=sys.stderr)
        sys.exit(1)
    grand_total = 0
    grand_failures = 0
    for file_name in files:
        total, failures = process_docx(file_name)
        grand_total += total
        grand_failures += len(failures)
    print("=" * 40)
    print(f"TOTAL: {grand_total} imagenes, {grand_failures} fallos")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
docz.py — Convert a .docx exam into the plain-text ".docx.txt" format used by
the exam pipeline.

WHAT IT PRODUCES
----------------
For each `FILE.docx`, writes `FILE.docx.txt` next to it. Every non-empty body
paragraph becomes ONE line, tagged so downstream tools (the report generator)
can classify it:

    *  <text>      paragraph whose first run is black / uncolored
    *+ <text>      paragraph whose first run has a (non-black) color

Inline run formatting is preserved as simple tags:

    <em>..</em>   italic      <u>..</u>   underline
    <sub>..</sub> subscript   <sup>..</sup> superscript

Text is ASCII-encoded with `xmlcharrefreplace`, so accented characters become
HTML numeric entities (e.g. "Patolog&#237;a"). That is intentional: the report
parser expects entities, not raw UTF-8.

IMPORTANT — OUTPUT IS A CONTRACT
--------------------------------
The report generator references this file by LINE NUMBER (e.g. "caso en línea
42"). Therefore this script's default output is kept BYTE-IDENTICAL to the
legacy docz.py behavior, including its quirks. Do not "improve" the emitted
lines without regenerating the reports.

KNOWN QUIRK: page-break markers ("!!****")
------------------------------------------
The legacy script tries to flag page transitions by checking whether the FIRST
run's raw XML contains "w:br" + 'type="page"'. That heuristic almost never
fires (a page break usually lives in a preceding empty paragraph), so only a
couple of misplaced "!!****" prefixes appear. Downstream does not rely on them,
so the default keeps the legacy behavior for compatibility. Pass
`--accurate-pagebreaks` to instead detect real breaks (w:br type=page and
w:lastRenderedPageBreak) on every run; note this CHANGES the emitted lines and
should only be used if the reports are regenerated afterwards.

SCOPE / LIMITS
--------------
* Only BODY paragraphs are converted. Tables are not (the CMCOMF exams have
  none). Headers/footers are ignored.
* Images are handled by the sibling tool `docx_page_images.py`.

USAGE
-----
    docz.py FILE.docx [FILE2.docx ...]
    docz.py DIRECTORY            # globs *.docx in that folder
    docz.py FILE.docx --accurate-pagebreaks
    docz.py FILE.docx --verbose   # also echo every converted line (old behavior)
"""

import os
import sys

import docx
from docx.shared import RGBColor


# ---------------------------------------------------------------------------
# Color classification
# ---------------------------------------------------------------------------
def paragraph_is_colored(paragraph):
    """True if the paragraph's FIRST run is colored (not default black).

    The exams are formatted so the leading run carries the marker color. We
    only look at the first run to stay byte-compatible with the legacy script.
    `font.color.rgb` returns None when no explicit color is set, and RAISES
    AttributeError for theme/scheme colors; we treat a theme color as "colored"
    (it is an explicit, non-default choice) instead of crashing.
    """
    color = paragraph.runs[0].font.color
    try:
        rgb = color.rgb
    except AttributeError:
        return True  # theme/scheme color = explicitly colored
    return bool(rgb and rgb != RGBColor(0, 0, 0))


# ---------------------------------------------------------------------------
# Page-break detection
# ---------------------------------------------------------------------------
def has_pagebreak_legacy(paragraph):
    """Legacy heuristic: literal 'w:br' + 'type="page"' in the FIRST run's XML.

    Kept only so default output matches the historical files byte-for-byte.
    """
    x = paragraph.runs[0]._element.xml
    return "w:br" in x and 'type="page"' in x


def has_pagebreak_accurate(paragraph):
    """Real detection: any page break or rendered page break in the paragraph."""
    return bool(
        paragraph._element.xpath(
            './/w:br[@w:type="page"] | .//w:lastRenderedPageBreak'
        )
    )


# ---------------------------------------------------------------------------
# Conversion
# ---------------------------------------------------------------------------
def convert_docx(file_name, accurate_pagebreaks=False, verbose=False):
    """Convert one .docx to `<file>.docx.txt`. Returns (out_path, n_lines)."""
    doc = docx.Document(file_name)
    out_path = file_name + ".txt"
    n_lines = 0

    has_pagebreak = has_pagebreak_accurate if accurate_pagebreaks else has_pagebreak_legacy

    with open(out_path, "wb") as f:
        for paragraph in doc.paragraphs:
            # Skip paragraphs that carry no visible text.
            if not paragraph.text.strip():
                continue
            # Paragraphs whose runs are empty are not real content either.
            if not paragraph.runs:
                continue

            # Line prefix: "* " for black/uncolored, "*+ " for colored.
            s = b"*+ " if paragraph_is_colored(paragraph) else b"* "

            # Append each run's text, wrapped in inline-format tags.
            for run in paragraph.runs:
                t = run.text.encode("ascii", "xmlcharrefreplace")
                if run.italic:
                    t = b"<em>" + t + b"</em>"
                if run.underline:
                    t = b"<u>" + t + b"</u>"
                if run.font.subscript:
                    t = b"<sub>" + t + b"</sub>"
                if run.font.superscript:
                    t = b"<sup>" + t + b"</sup>"
                s += t

            # Optional page-transition marker (see docstring; default = legacy).
            if has_pagebreak(paragraph):
                f.write("!!****".encode())

            f.write(s + b"\n")
            n_lines += 1
            if verbose:
                print(s.decode("ascii", "replace"))

    return out_path, n_lines


def collect_inputs(args):
    """Expand args into .docx paths (directories are globbed, non-recursive)."""
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
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    accurate = "--accurate-pagebreaks" in sys.argv
    verbose = "--verbose" in sys.argv

    if not args:
        print(__doc__)
        sys.exit(1)

    files = collect_inputs(args)
    if not files:
        print("No se encontraron archivos .docx.", file=sys.stderr)
        sys.exit(1)

    for file_name in files:
        out_path, n_lines = convert_docx(file_name, accurate, verbose)
        print(f"{file_name} -> {out_path} ({n_lines} lineas)")


if __name__ == "__main__":
    main()

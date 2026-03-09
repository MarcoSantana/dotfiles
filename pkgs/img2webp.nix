{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "img2webp";

  # ImageMagick for conversion, findutils for recursive search
  runtimeInputs = [ pkgs.imagemagick pkgs.findutils ];

  text = ''
    # Get the name of the current directory to form the output directory name
    ORIGIN_DIR_NAME=$(basename "$PWD")
    # Place converted images in a directory named [origin_dir]_webp_converted as a sibling folder
    TARGET_DIR="../''${ORIGIN_DIR_NAME}_webp_converted"

    echo "--- Image to WebP Recursive Converter ---"
    echo "Source: $PWD"
    echo "Target: $TARGET_DIR"
    echo "----------------------------------------"

    mkdir -p "$TARGET_DIR"

    # Find all image files recursively (case-insensitive extensions)
    # Exclude the target directory if it happens to be inside (unlikely as sibling)
    find . -type f -regextype posix-extended -iregex '.*\.(jpg|jpeg|png|bmp|tiff|gif|webp)' | while read -r img; do
        # Get relative path (strips leading ./)
        rel_path="''${img#./}"
        
        # Define target path (replace extension with .webp)
        # Using string manipulation to ensure the final extension is .webp
        target_path="$TARGET_DIR/''${rel_path%.*}.webp"
        
        # Skip if the source is already the target (prevents infinite loop if run repeatedly)
        if [[ "$(realpath "$img")" == "$(realpath "$target_path")" ]]; then
            continue
        fi

        # Create target subdirectory structure
        mkdir -p "$(dirname "$target_path")"
        
        # Only convert if source is newer than target (incremental backup logic)
        if [[ "$img" -nt "$target_path" ]]; then
            echo "Converting: $rel_path"
            # Using 'magick' (v7) for conversion
            magick "$img" "$target_path"
        else
            echo "Skipping (already current): $rel_path"
        fi
    done

    echo "----------------------------------------"
    echo "Done! Converted images are in: $TARGET_DIR"
  '';
}

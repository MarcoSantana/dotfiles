{ pkgs, ... }:

# To use this in NixOS, add it to your configuration.nix:
# environment.systemPackages = [ (pkgs.callPackage ./webp-converter.nix {}) ];
# Or in Home Manager:
# home.packages = [ (pkgs.callPackage ./webp-converter.nix {}) ];

pkgs.writeShellApplication {
  name = "img2webp";

  runtimeInputs = [ pkgs.imagemagick pkgs.findutils ];

  text = ''
    # Get the name of the current directory to form the output directory name
    ORIGIN_DIR_NAME=$(basename "$PWD")
    TARGET_DIR="../''${ORIGIN_DIR_NAME}_webp_converted"

    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"

    # Find image files (case-insensitive extensions)
    # Using find -iregex for case-insensitive matching
    find . -type f -regextype posix-extended -iregex '.*\.(jpg|jpeg|png|bmp|tiff|gif)' | while read -r img; do
        # Remove leading './'
        rel_path="''${img#./}"
        # Target filename with .webp extension
        # Using string manipulation to replace the extension
        target_path="$TARGET_DIR/''${rel_path%.*}.webp"
        
        # Create the same subdirectory structure in the target folder
        mkdir -p "$(dirname "$target_path")"
        
        # Skip if target already exists and is newer than source (optional optimization)
        if [[ "$img" -nt "$target_path" ]]; then
            echo "Converting: $rel_path"
            magick "$img" "$target_path"
        else
            echo "Skipping (already up to date): $rel_path"
        fi
    done

    echo "Conversion complete! Files are in $TARGET_DIR"
  '';
}

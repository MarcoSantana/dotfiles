{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Vector & Raster Editors
    gimp
    inkscape
    krita
    
    # Pixel Art & Sprite Work
    pixelorama  # The "pretty UI" FOSS pixel art tool (built with Godot)
    libresprite # FOSS fork of Aseprite
    
    # 3D & Animation
    blender
    
    # Graphics Utilities
    optipng     # Optimize PNGs
    jpegoptim   # Optimize JPEGs
    fontforge   # Font editor
    exiftool    # Metadata manipulation
    
    # Screenshots & Quick Editing (Wayland optimized)
    swappy      # Simple image editor for screenshots (arrows, text, etc)
    
    # Image Viewers
    imv         # Wayland image viewer
    nsxiv       # Fast, simple image viewer
  ];
}

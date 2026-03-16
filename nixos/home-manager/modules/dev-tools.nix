{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Runtimes & SDKs
    nodejs_22
    fnm # Fast Node Manager (Alternative to nvm)
    python3
    python3Packages.pip
    python3Packages.python-docx
    go
    rustup
    luajit
    gcc
    gnumake

    # Containers
    supabase-cli
    podman-desktop
    lazydocker
    dive # Docker image explorer

    # LSPs (Language Servers)
    nixd # Nix
    nil # Nix (alternative)
    lua-language-server # Lua
    pyright # Python
    gopls # Go
    typescript-language-server # TS/JS
    vue-language-server # Vue 3
    vscode-langservers-extracted # HTML/CSS/JSON/ESLint
    bash-language-server # Bash
    yaml-language-server # YAML
    dockerfile-language-server-nodejs # Docker
    terraform-ls # Terraform
    marksman # Markdown
    taplo # TOML
    tailwindcss-language-server
    
    # Formatters & Linters
    nixpkgs-fmt
    stylua
    black
    isort
    nodePackages.prettier
    shfmt
    shellcheck
    hadolint # Docker linter
    sqlfluff # SQL linter

    # GUI Dev Clients
    postman
    dbeaver-bin
    
    # Debuggers (DAP)
    delve # Go
    python3Packages.debugpy # Python

    # Extra CLI Power
    ripgrep
    fd
    jq
    yq-go
    fzf
    sqlite
  ];

  home.sessionVariables = {
    GOROOT = "${pkgs.go}/share/go";
  };
}

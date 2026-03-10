{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Runtimes & SDKs
    nodejs_22
    python3
    go
    rustup
    luajit
    gcc
    gnumake

    # LSPs (Language Servers)
    nixd # Nix
    nil # Nix (alternative)
    lua-language-server # Lua
    pyright # Python
    gopls # Go
    typescript-language-server # TS/JS
    vscode-langservers-extracted # HTML/CSS/JSON/ESLint
    bash-language-server # Bash
    yaml-language-server # YAML
    dockerfile-language-server-nodejs # Docker
    terraform-ls # Terraform
    marksman # Markdown
    taplo # TOML
    
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

# 1. Oh My Zsh Core
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git nvm) # Removed 'z' to avoid zoxide conflict
source $ZSH/oh-my-zsh.sh

# 2. Environment & Version Managers
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/home/msantana/.opencode/bin:$PATH"
eval "$(~/.local/bin/mise activate)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# 3. FZF Logic (The Fix)
# We define the variables BEFORE sourcing the script
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always {} 2>/dev/null || tree -C {} | head -200'"

# Sourcing the specific script that creates the 'fzf-history-widget'
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# 4. Manual Widget Binding (If the script above fails to bind them)
# This ensures 'CTRL-R' and 'CTRL-T' are mapped to the fzf functions
bindkey -e
[[ -n "$(typeset -f fzf-history-widget)" ]] && bindkey '^R' fzf-history-widget
[[ -n "$(typeset -f fzf-file-widget)" ]] && bindkey '^T' fzf-file-widget
[[ -n "$(typeset -f fzf-cd-widget)" ]] && bindkey '\ec' fzf-cd-widget

# 5. Tooling & Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"
export EDITOR='nvim'

# 6. Modern Aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --git"
alias cat="bat"
# # 1. Oh My Zsh Core
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="robbyrussell"
# plugins=(git nvm) # Removed 'z' to avoid zoxide conflict
# source $ZSH/oh-my-zsh.sh
#
# # 2. Environment & Version Managers
# export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/home/msantana/.opencode/bin:$PATH"
# eval "$(~/.local/bin/mise activate)"
# eval "$(starship init zsh)"
# eval "$(zoxide init zsh)"
#
# # 3. FZF Logic (The Fix)
# # We define the variables BEFORE sourcing the script
# export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always {} 2>/dev/null || tree -C {} | head -200'"
#
# # Sourcing the specific script that creates the 'fzf-history-widget'
# if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
#   source /usr/share/doc/fzf/examples/key-bindings.zsh
# fi
#
# # 4. Manual Widget Binding (If the script above fails to bind them)
# # This ensures 'CTRL-R' and 'CTRL-T' are mapped to the fzf functions
# bindkey -e
# [[ -n "$(typeset -f fzf-history-widget)" ]] && bindkey '^R' fzf-history-widget
# [[ -n "$(typeset -f fzf-file-widget)" ]] && bindkey '^T' fzf-file-widget
# [[ -n "$(typeset -f fzf-cd-widget)" ]] && bindkey '\ec' fzf-cd-widget
#
# # 5. Tooling & Node
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
# export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"
# export EDITOR='nvim'
#
# # 6. Modern Aliases
# alias ls="eza --icons --group-directories-first"
# alias ll="eza -lah --icons --git"
# alias cat="bat"
# # Path to your Oh My Zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
#
# # Theme and Plugin Configuration
# ZSH_THEME="robbyrussell"
# # Removed 'z' to avoid conflict with zoxide [cite: 19]
# plugins=(git nvm) 
#
# # Initialize Oh My Zsh
# source $ZSH/oh-my-zsh.sh
#
# # --- Tool Initialization (Mise, Starship, Zoxide) ---
# export PATH="$HOME/.local/bin:$PATH"
# eval "$(~/.local/bin/mise activate)"
# eval "$(starship init zsh)"
# eval "$(zoxide init zsh)"
#
# # --- FZF Configuration & Keybinds ---
# # Using fd for speed and hidden files 
# export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always {} 2>/dev/null || tree -C {} | head -200'"
#
# # Load Ubuntu/Pop!_OS specific fzf scripts
# if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
#   source /usr/share/doc/fzf/examples/key-bindings.zsh
# fi
#
# if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
#   source /usr/share/doc/fzf/examples/completion.zsh
# fi
#
# # MANUALLY FORCE BINDINGS (The "Cool" stuff)
# # CTRL-T: Paste the selected file path into the command line
# # CTRL-R: Search through command history
# # ALT-C:  cd into the selected directory
# bindkey -e
# bindkey '^T' fzf-file-widget
# bindkey '^R' fzf-history-widget
# bindkey '\ec' fzf-cd-widget
#
# # --- System & Personal Paths ---
# export PATH="$HOME/.cargo/bin:/home/msantana/.opencode/bin:$PATH"
# export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"
# export EDITOR='nvim'
#
# # --- NVM (Node Version Manager) ---
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
#
# # --- Aliases ---
# alias ls="eza --icons --group-directories-first"
# alias ll="eza -lah --icons --git"
# alias cat="bat"
# # Path to your Oh My Zsh installation.
# export ZSH="$HOME/.oh-my-zsh" 
#
# # Theme and Plugin Configuration
# ZSH_THEME="robbyrussell"
# plugins=(git nvm) # Removed 'z' because you use 'zoxide' 
#
# # Initialize Oh My Zsh
# source $ZSH/oh-my-zsh.sh
#
# # --- Environment & Tool Initialization ---
#
# # Mise (formerly rtx) activation 
# export PATH="$HOME/.local/bin:$PATH"
# eval "$(~/.local/bin/mise activate)"
#
# # Starship Prompt
# eval "$(starship init zsh)"
#
# # Zoxide (better 'cd')
# eval "$(zoxide init zsh)" 
#
# # Cargo / Rust
# export PATH="$HOME/.cargo/bin:$PATH"
#
# # Opencode / Custom bin
# export PATH="/home/msantana/.opencode/bin:$PATH"
#
# # --- FZF Configuration ---
#
# # Global FZF Defaults
# export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git" 
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND" 
# export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git" 
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always {} 2>/dev/null || tree -C {} | head -200'" 
#
# # Source Ubuntu-specific FZF scripts
# [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh 
# [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh 
#
# # Ensure Emacs keybindings (for Home/End and Alt keys)
# bindkey -e
#
# # --- Node Version Manager (NVM) ---
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ]          && source "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
#
# # --- Containers & Docker ---
# export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"
#
# # --- Personal Aliases ---
# alias ll="eza -lah --icons --git"
# alias cat="bat"
#
# # Preferred editor
# export EDITOR='nvim'
# # If you come from bash you might have to change your $PATH.
# # export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
#
# # Path to your Oh My Zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
#
# # Set name of the theme to load --- if set to "random", it will
# # load a random theme each time Oh My Zsh is loaded, in which case,
# # to know which specific one was loaded, run: echo $RANDOM_THEME
# # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
#
# # Set list of themes to pick from when loading at random
# # Setting this variable when ZSH_THEME=random will cause zsh to load
# # a theme from this variable instead of looking in $ZSH/themes/
# # If set to an empty array, this variable will have no effect.
# # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
#
# # Uncomment the following line to use case-sensitive completion.
# # CASE_SENSITIVE="true"
#
# # Uncomment the following line to use hyphen-insensitive completion.
# # Case-sensitive completion must be off. _ and - will be interchangeable.
# # HYPHEN_INSENSITIVE="true"
#
# # Uncomment one of the following lines to change the auto-update behavior
# # zstyle ':omz:update' mode disabled  # disable automatic updates
# # zstyle ':omz:update' mode auto      # update automatically without asking
# # zstyle ':omz:update' mode reminder  # just remind me to update when it's time
#
# # Uncomment the following line to change how often to auto-update (in days).
# # zstyle ':omz:update' frequency 13
#
# # Uncomment the following line if pasting URLs and other text is messed up.
# # DISABLE_MAGIC_FUNCTIONS="true"
#
# # Uncomment the following line to disable colors in ls.
# # DISABLE_LS_COLORS="true"
#
# # Uncomment the following line to disable auto-setting terminal title.
# # DISABLE_AUTO_TITLE="true"
#
# # Uncomment the following line to enable command auto-correction.
# # ENABLE_CORRECTION="true"
#
# # Uncomment the following line to display red dots whilst waiting for completion.
# # You can also set it to another string to have that shown instead of the default red dots.
# # e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# # Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# # COMPLETION_WAITING_DOTS="true"
#
# # Uncomment the following line if you want to disable marking untracked files
# # under VCS as dirty. This makes repository status check for large repositories
# # much, much faster.
# # DISABLE_UNTRACKED_FILES_DIRTY="true"
#
# # Uncomment the following line if you want to change the command execution time
# # stamp shown in the history command output.
# # You can set one of the optional three formats:
# # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# # or set a custom format using the strftime function format specifications,
# # see 'man strftime' for details.
# # HIST_STAMPS="mm/dd/yyyy"
#
# # Would you like to use another custom folder than $ZSH/custom?
# # ZSH_CUSTOM=/path/to/new-custom-folder
#
# # Which plugins would you like to load?
# # Standard plugins can be found in $ZSH/plugins/
# # Custom plugins may be added to $ZSH_CUSTOM/plugins/
# # Example format: plugins=(rails git textmate ruby lighthouse)
# # Add wisely, as too many plugins slow down shell startup.
# plugins=(git nvm z)
#
# source $ZSH/oh-my-zsh.sh
#
# # User configuration
#
# # export MANPATH="/usr/local/man:$MANPATH"
# export PATH="$HOME/.cargo/bin:$PATH"
# # You may need to manually set your language environment
# # export LANG=en_US.UTF-8
#
# # Preferred editor for local and remote sessions
# # if [[ -n $SSH_CONNECTION ]]; then
# #   export EDITOR='vim'
# # else
# #   export EDITOR='nvim'
# # fi
#
# # Compilation flags
# # export ARCHFLAGS="-arch $(uname -m)"
#
# # Set personal aliases, overriding those provided by Oh My Zsh libs,
# # plugins, and themes. Aliases can be placed here, though Oh My Zsh
# # users are encouraged to define aliases within a top-level file in
# # the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# # - $ZSH_CUSTOM/aliases.zsh
# # - $ZSH_CUSTOM/macos.zsh
# # For a full list of active aliases, run `alias`.
# #
# # starship
# eval "$(starship init zsh)"
#
#
# # aliases
# alias ls="eza --icons --group-directories-first"
# alias ll="eza -lah --icons --git"
# alias cat="bat"
#
#
# # Podman rootless socket (set by popOs_podman_setup.sh)
# export DOCKER_HOST="unix:///run/user/1000/podman/podman.sock"
#
# # NVM (Node Version Manager) — added by popOs_podman_setup.sh
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ]          && source "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
#
# # opencode
# export PATH=/home/msantana/.opencode/bin:$PATH
# export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview \"bat --color=always {} 2>/dev/null || tree -C {} | head -200\""
# eval "$(zoxide init zsh)"
#
# # fzf defaults
# export FZF_DEFAULT_COMMAND="fd --type f"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
# # Example aliases
# # alias zshconfig="mate ~/.zshrc"
# # alias ohmyzsh="mate ~/.oh-my-zsh"
# #
# # fzf
# # [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# # fzf keybindings (Ubuntu fix)
# [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
#
# # fzf completion (opcional pero bueno)
# [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
# bindkey -e
# export FZF_DEFAULT_COMMAND="fd --type f"
# # path
# export PATH="$HOME/.local/bin:$PATH"
# eval "$(~/.local/bin/mise activate)"

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(~/.local/bin/mise activate)"

# ─── CLI tools (mise-managed) ────────────────────────────────────────────────

command -v zoxide >/dev/null && eval "$(zoxide init bash)"

command -v fzf >/dev/null && {
    eval "$(fzf --bash)"
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --color=bg+:#292e42,spinner:#bb9af7,hl:#7aa2f7,fg:#a9b1d6,header:#7aa2f7,info:#565f89,pointer:#7dcfff,marker:#9ece6a,fg+:#c0caf5,prompt:#7dcfff,hl+:#7aa2f7'
}

command -v bat >/dev/null && alias cat='bat --paging=never'

if command -v eza >/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -la --icons=auto --git --group-directories-first'
    alias la='eza -a --icons=auto --group-directories-first'
    alias l='eza -laa --icons=auto --git --group-directories-first'
    alias tree='eza --tree --icons=auto'
fi

command -v direnv >/dev/null && eval "$(direnv hook bash)"

# opencode
export PATH=/home/msantana/.opencode/bin:$PATH


# Added by Antigravity CLI installer
export PATH="/home/msantana/.local/bin:$PATH"

# ─── Prompt ──────────────────────────────────────────────────────────────────
# Two-line prompt: time · user@host · path · git state · cmd duration · exit code

PROMPT_DIRTRIM=4

_prompt_timer() {
    [[ $BASH_COMMAND == "$PROMPT_COMMAND" ]] && return
    __prompt_t0=$EPOCHREALTIME
}

_prompt_git() {
    GIT_PROMPT_SEG=""
    command git rev-parse --is-inside-work-tree &>/dev/null || return 0
    local out head branch seg
    out=$(command git status --porcelain=v1 -b 2>/dev/null) || return 0
    head=${out%%$'\n'*}
    if [[ $head == '## No commits yet on '* ]]; then
        branch="${head#'## No commits yet on '}"
    else
        branch=${head#'## '}
        branch=${branch%%...*}
        [[ $branch == 'HEAD (no branch)' ]] && branch='(detached)'
    fi
    [[ -n $branch ]] || return 0
    seg=$'\[\e[38;2;187;154;247m\]'"$branch"$'\[\e[0m\]'
    [[ $head =~ ahead\ ([0-9]+) ]] && seg+=" "$'\[\e[38;2;158;206;106m\]'"↑${BASH_REMATCH[1]}"$'\[\e[0m\]'
    [[ $head =~ behind\ ([0-9]+) ]] && seg+=" "$'\[\e[38;2;247;118;142m\]'"↓${BASH_REMATCH[1]}"$'\[\e[0m\]'
    local rest=${out#*$'\n'} line x y ns=0 nm=0 nu=0 nc=0
    if [[ $rest != "$out" ]]; then
        while IFS= read -r line; do
            x=${line:0:1} y=${line:1:1}
            case $x in
                "?") ((nu++)) ;;
                "U") ((nc++)) ;;
                [MADRC]) ((ns++)) ;;
            esac
            case $y in [MDU]) ((nm++)) ;; esac
        done <<<"$rest"
    fi
    ((ns)) && seg+=" "$'\[\e[38;2;224;175;104m\]'"✚$ns"$'\[\e[0m\]'
    ((nm)) && seg+=" "$'\[\e[38;2;247;118;142m\]'"✱$nm"$'\[\e[0m\]'
    ((nc)) && seg+=" "$'\[\e[38;2;255;121;198m\]'"✖$nc"$'\[\e[0m\]'
    ((nu)) && seg+=" "$'\[\e[38;5;245m\]'"?$nu"$'\[\e[0m\]'
    GIT_PROMPT_SEG=$seg
}

_prompt_command() {
    local st=$?
    local r=$'\[\e[0m\]' dim=$'\[\e[38;5;245m\]'
    local blue=$'\[\e[38;2;122;162;247m\]'
    local green=$'\[\e[38;2;158;206;106m\]'
    local red=$'\[\e[38;2;247;118;142m\]'
    local cyan=$'\[\e[38;2;115;218;202m\]'
    case $TERM in xterm*|rxvt*|kitty|ghostty|screen*|tmux*|*256color*)
        printf '\033]0;%s@%s: %s\007' "$USER" "${HOSTNAME%%.*}" "${PWD/#"$HOME"/~}" ;;
    esac
    _prompt_git
    local dur=""
    if [[ -n ${__prompt_t0:-} && -n ${EPOCHREALTIME:-} ]]; then
        local us=$(( ${EPOCHREALTIME/./} - ${__prompt_t0/./} ))
        if (( us > 1000000 )); then
            printf -v dur '%d.%ds' $(( us / 1000000 )) $(( (us % 1000000) / 100000 ))
            dur=" $dim$dur$r"
        fi
        __prompt_t0=
    fi
    local arrow=$green tail=""
    (( st )) && { arrow=$red; tail=" $red✘ $st$r"; }
    PS1="\n$dim╭─$r ${debian_chroot:+($debian_chroot)}$blue\t$r $dim·$r "
    PS1+="$green\u$r@$dim\h$r $dim·$r $cyan\w$r"
    [[ -n ${GIT_PROMPT_SEG:-} ]] && PS1+=" $GIT_PROMPT_SEG"
    PS1+="$dur$tail"
    PS1+="\n$dim╰─$r$arrow❯$r "
}

PROMPT_COMMAND=_prompt_command
[[ -n ${EPOCHREALTIME:-} ]] && trap _prompt_timer DEBUG

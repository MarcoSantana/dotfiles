alias composer='php composer.phar'
alias lsl='ls -l'
#color in MAN pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
#shortcuts
# save fingers!
alias l='ls'
# long listing of ls
alias ll='ls -l'
# colors and file types alias lf='ls -CF'
# sort by filename extension alias lx='ls -lXB'
# sort by size
alias lk='ls -lSr'
# show hidden files
alias la='ls -A'
# sort by date
alias lt='ls -ltr'
alias postgresql.server='function pgsql_server() { case $1 in "start") echo "Trying to start PostgreSQL..."; pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start ;; "stop") echo "Trying to stop PostgreSQL..."; pg_ctl -D /usr/local/var/postgres stop -s -m fast ;; esac }; pgsql_server'

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="jnrowe"

plugins=(
    git
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# check the dnf plugins commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dnf


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias grab="$HOME/go/bin/grab"
alias nvpower="watch -n 2 cat /proc/driver/nvidia/gpus/0000:01:00.0/power"
alias nvwatch='watch -n 2 cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status'
alias getgithubkey='cat ~/Documents/github_key | wl-copy'
alias getopenaikey='cat ~/Documents/openaiapikey | wl-copy'
alias fzfview="fzf --preview='cat {}'"

alias nvrun='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia'

alias hunterssh="ssh -J don.suhanda95@eniac.cs.hunter.cuny.edu don.suhanda95@cslab10"

alias ffviii='~/.local/bin/launch-ffviii.sh'

# grab and mcat
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.cargo/env"

alias claude="/home/don/.claude/local/claude"

# --- mkcd: mkdir -p then cd ---
mkcd() {
  if [[ -z "$1" ]]; then
    echo "usage: mkcd <path>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

# ---- fkill: interactive/process-name killer, sorted by %MEM with colors ----
# Usage:
#   fkill                 # interactive picker (TAB to multi-select, ENTER to kill)
#   fkill discord         # kill all procs whose cmdline matches "discord" (SIGTERM)
#   fkill discord -9      # force kill with SIGKILL
fkill() {
  # name/pattern mode
  if [[ -n "$1" ]]; then
    local sig="-TERM"
    [[ "$2" == "-9" ]] && sig="-KILL"
    local matches
    matches=$(pgrep -fa -- "$1") || { echo "no matching processes"; return 1; }
    echo "matches:"
    echo "$matches"
    read -k "REPLY?kill ${#${(f)matches}} process(es) with signal ${sig#-}? [y/N] "
    echo
    [[ "$REPLY" == [yY] ]] || return 1
    echo "$matches" | awk '{print $1}' | xargs -r kill "$sig"
    return
  fi

  command -v fzf >/dev/null 2>&1 || { echo "fzf not installed (sudo dnf install fzf)"; return 1; }

  # thresholds for color (tweak if you want)
  local hi=5   # %MEM >= hi   -> red
  local mid=1  # %MEM >= mid  -> yellow, else green

  # Build table with ANSI colors; keep header uncolored. Sort by %MEM desc.
  local table
  table=$(
    ps -eo pid,ppid,%mem,%cpu,comm,args --sort=-%mem \
    | awk -v HI="$hi" -v MID="$mid" '
      BEGIN {
        ESC = sprintf("\033");
        clr = ESC "[0m";
        green = ESC "[32m"; yellow = ESC "[33m"; red = ESC "[31m";
        # column headers
        printf "PID   PPID  %%MEM  %%CPU  COMMAND              FULL_CMD\n";
      }
      NR==1 { next } # skip ps header (we printed our own)
      {
        pid=$1; ppid=$2; mem=$3+0; cpu=$4+0; cmd=$5;
        args=""; for (i=6;i<=NF;i++) args = args (i==6?"":" ") $i;
        color = (mem>=HI)?red:((mem>=MID)?yellow:green);
        # align columns; command column fixed width for readability
        printf "%s%5s %5s %5.1f %5.1f  %-20s%s %s%s\n",
               color, pid, ppid, mem, cpu, cmd, clr, args, clr;
      }'
  ) || return 1

  # Interactive picker with colors
  local sel
  sel=$(echo "$table" \
        | fzf --ansi --multi \
              --prompt='kill> ' \
              --header='TAB=multi  ENTER=kill  (sorted by %MEM: red=high, yellow=mid, green=low)' \
              --bind 'ctrl-k:toggle-all') || return 1

  # Strip ANSI + header, extract PID, kill
  echo "$sel" \
    | sed -E "s/\x1B\[[0-9;]*m//g" \
    | awk 'NR>1 {print $1}' \
    | xargs -r kill -TERM
}

export PATH=~/.npm-global/bin:$PATH

if [[ -f ~/.zsh_aliases ]]; then
  source ~/.zsh_aliases
fi

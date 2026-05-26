export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="jnrowe"

is_mac=false
[[ "$(uname)" == "Darwin" ]] && is_mac=true

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# when you open the terminal for the first time this appears
fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
# Requires: fzf (brew install fzf on Mac)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# needs lsd (brew install lsd on Mac)
alias ls='lsd'
alias l='ls -lah'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias grab="$HOME/.local/bin/grab"
alias fzfview="fzf --preview='cat {}'"
alias hunterssh="ssh -J don.suhanda95@eniac.cs.hunter.cuny.edu don.suhanda95@cslab10"

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH

# --- mkcd: mkdir -p then cd ---
mkcd() {
  if [[ -z "$1" ]]; then
    echo "usage: mkcd <path>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

if [[ -f ~/.zsh_aliases ]]; then
  source ~/.zsh_aliases
fi
export MANPATH="$HOME/.local/share/man:$MANPATH"

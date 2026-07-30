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

# keep mac on after lid close
alias keepwake="caffeinate -i -d &"
alias stopwake='pkill caffeinate'

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# --- mkcd: mkdir -p then cd ---
mkcd() {
  if [[ -z "$1" ]]; then
    echo "usage: mkcd <path>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

# --- kbmap: toggle 8BitDo Retro Keyboard modifier remap ---
# custom profile:  CapsLock->Option, Option<->Command  (Ctrl & Globe untouched)
# off:             stock behavior (empty mapping)
# targets ONLY the 8BitDo by vendor/product id, apple keyboard is left alone.
kbmap() {
  local match='{"ProductID":0x5200,"VendorID":0x2dc8}'
  # capslock(39)->opt(E2), opt(E2)->cmd(E3), cmd(E3)->opt(E2)
  local profile='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E2},{"HIDKeyboardModifierMappingSrc":0x7000000E2,"HIDKeyboardModifierMappingDst":0x7000000E3},{"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E2}]}'

  # is anything mapped right now? readback shows the src code when active
  if hidutil property --matching "$match" --get "UserKeyMapping" 2>/dev/null | grep -q 30064771129; then
    hidutil property --matching "$match" --set '{"UserKeyMapping":[]}' >/dev/null
    echo "8BitDo: default"
  else
    hidutil property --matching "$match" --set "$profile" >/dev/null
    echo "8BitDo: custom (caps->opt, opt<->cmd)"
  fi
  # debug: uncomment to eyeball the raw mapping
  # hidutil property --matching "$match" --get "UserKeyMapping"
}

if [[ -f ~/.zsh_aliases ]]; then
  source ~/.zsh_aliases
fi
export MANPATH="$HOME/.local/share/man:$MANPATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="fishy"
DISABLE_AUTO_UPDATE="true"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
alias btop="btop --utf-force"

function reload {
  source ~/.zshrc
   exec zsh
}

export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="fishy"
DISABLE_AUTO_UPDATE="true"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
alias btop="btop --utf-force"
alias public-ip= "curl 4.ipcheck.ing/geo"
alias public-ip6= "curl 6.ipcheck.ing/geo"

function reload {
  source ~/.zshrc
   exec zsh
}

# ...standard oh-my-zsh boilerplate goes here...
ZSH=${ZSH:-$HOME/.oh-my-zsh}
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}

# clone your external plugins if needed
external_plugins=(
  zsh-users/zsh-autosuggestions
  marlonrichert/zsh-hist
  zsh-users/zsh-syntax-highlighting
)
for repo in $external_plugins; do
  if [[ ! -d $ZSH_CUSTOM/${repo:t} ]]; then
    git clone https://github.com/${repo} $ZSH_CUSTOM/plugins/${repo:t}
  fi
done

# set your normal oh-my-zsh plugins
plugins=(
  git
  magic-enter
)

# now add your external plugins to your OMZ plugins list
plugins+=(${external_plugins:t})

# then source oh-my-zsh
source $ZSH/oh-my-zsh.sh

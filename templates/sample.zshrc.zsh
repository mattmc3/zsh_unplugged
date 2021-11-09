ZPLUGINDIR=$HOME/.zsh/plugins

# if you want to use unplugged, you can copy/paste plugin-clone here, or just pull the repo
if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  git clone https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/unplugged.zsh

plugins=(
  # core plugins
  mafredri/zsh-async
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search

  # user plugins
  rupa/z
  peterhurford/up.zsh
  rummik/zsh-tailf

  # prompts
  sindresorhus/pure

  # load this one last
  zsh-users/zsh-syntax-highlighting
)
for plugin in $plugins; do
    plugin-clone https://github.com/${plugin}.git
    source $ZPLUGINDIR/${plugin:t}/init.zsh
done
unset plugin

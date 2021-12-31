# ...standard prezto boilerplate goes here...
ZPREZTODIR=${ZPREZTODIR:-${ZDOTDIR:-$HOME}/.prezto}

# clone your external plugins if needed
external_plugins=(
  zsh-users/zsh-autosuggestions
  marlonrichert/zsh-hist
  mattmc3/zman
)
for repo in $external_plugins; do
  if [[ ! -d $ZPREZTODIR/contrib/${repo:t} ]]; then
    git clone https://github.com/${repo} $ZPREZTODIR/contrib/${repo:t}/external
    echo "source \${0:A:h}/external/${repo:t}.plugin.zsh" > $ZPREZTODIR/contrib/${repo:t}/init.zsh
  fi
done

# be sure to add these plugins to your .zpreztorc
# zstyle ':prezto:load' pmodule \
#   ... \
#   z \
#   zsh-hist \
#   ... \
#   zman

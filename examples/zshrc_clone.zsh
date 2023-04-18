# You can also separate the clone and load portions for more advanced plugin loads

# where should we download your Zsh plugins?
ZPLUGINDIR=${ZDOTDIR:-$HOME/.config/zsh}/plugins

# declare a simple plugin-clone function, leaving the user to load plugins themselves
function plugin-clone {
  local repo plugdir initfile initfiles=()
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugdir
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh,sh,zsh-theme}(N))
      (( $#initfiles )) && ln -sf $initfiles[1] $initfile
    fi
  done
}

function plugin-source {
  local plugdir
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for plugdir in $@; do
    [[ $plugdir = /* ]] || plugdir=$ZPLUGINDIR/$plugdir
    fpath+=$plugdir
    local initfile=$plugdir/${plugdir:t}.plugin.zsh
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# make a github repo plugins list
repos=(
  # not-sourcable plugins
  romkatv/zsh-bench

  # projects with nested plugins
  belak/zsh-utils
  ohmyzsh/ohmyzsh

  # regular plugins
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  zdharma-continuum/fast-syntax-highlighting
)
plugin-clone $repos

# handle non-standard plugins
export PATH="$ZPLUGINDIR/zsh-bench:$PATH"
for file in $ZPLUGINDIR/ohmyzsh/lib/*.zsh; do
  source $file
done

# source other plugins
plugins=(
  zsh-utils/history
  zsh-utils/complete
  zsh-utils/utility
  ohmyzsh/plugins/magic-enter
  ohmyzsh/plugins/history-substring-search
  ohmyzsh/plugins/z
  fast-syntax-highlighting
  zsh-autosuggestions
)
plugin-source $plugins

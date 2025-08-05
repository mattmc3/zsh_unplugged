# You can also separate the clone and load portions for more advanced plugin loads

# where should we download your Zsh plugins?
ZPLUGINDIR=${ZDOTDIR:-$HOME/.config/zsh}/plugins

# declare a simple plugin-clone function, leaving the user to load plugins themselves
function plugin-clone {
  local plugin repo commitsha plugdir initfile initfiles=()
  : ${ZPLUGINDIR:=${ZDOTDIR:-~/.config/zsh}/plugins}
  for plugin in $@; do
    repo="$plugin"
    clone_args=(-q --depth 1 --recursive --shallow-submodules)
    # Pin repo to a specific commit sha if provided
    if [[ "$plugin" == *'@'* ]]; then
      repo="${plugin%@*}"
      commitsha="${plugin#*@}"
      clone_args+=(--no-checkout)
    fi
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone "${clone_args[@]}" https://github.com/$repo $plugdir
      if [[ -n "$commitsha" ]]; then
        git -C $plugdir fetch -q origin "$commitsha"
        git -C $plugdir checkout -q "$commitsha"
      fi
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) && ln -sf $initfiles[1] $initfile
    fi
  done
}

function plugin-source {
  local plugdir initfile
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for plugdir in $@; do
    [[ $plugdir = /* ]] || plugdir=$ZPLUGINDIR/$plugdir
    fpath+=$plugdir
    initfile=$plugdir/${plugdir:t}.plugin.zsh
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# make a github repo plugins list
repos=(
  # not-sourcable plugins
  'romkatv/zsh-bench@d7f9f821688bdff9365e630a8aaeba1fd90499b1'

  # projects with nested plugins
  'belak/zsh-utils@3ebd1e4038756be86da095b88f3713170171aec1'
  'ohmyzsh/ohmyzsh@a6beb0f5958e935d33b0edb6d4470c3d7c4e8917'

  # regular plugins
  'zsh-users/zsh-autosuggestions@85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5'
  'zsh-users/zsh-history-substring-search@87ce96b1862928d84b1afe7c173316614b30e301'
  'zdharma-continuum/fast-syntax-highlighting@3d574ccf48804b10dca52625df13da5edae7f553'
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
  zsh-utils/completion
  zsh-utils/utility
  ohmyzsh/plugins/magic-enter
  ohmyzsh/plugins/history-substring-search
  ohmyzsh/plugins/z
  fast-syntax-highlighting
  zsh-autosuggestions
)
plugin-source $plugins

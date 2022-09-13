# where should we download your Zsh plugins?
#ZPLUGINDIR=$ZDOTDIR/plugins

# declare a simple plugin-load function
function plugin-load {
  local repo plugdir initfile
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugdir
    fi
    if [[ ! -e $initfile ]]; then
      local -a initfiles=($plugdir/*.plugin.{z,}sh(N) $plugdir/*.{z,}sh{-theme,}(N))
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf "${initfiles[1]}" "$initfile"
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# make a github repo plugins list
plugins=(
  sindresorhus/pure
  mattmc3/zman
  rupa/z
  rummik/zsh-tailf
  peterhurford/up.zsh
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search

  # load these at hypersonic load speeds with zsh-defer
  romkatv/zsh-defer
  olets/zsh-abbr
  zdharma-continuum/fast-syntax-highlighting
)
plugin-load $plugins

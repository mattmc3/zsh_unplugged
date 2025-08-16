# zsh_unplugged - https://github.com/mattmc3/zsh_unplugged
#
# A simple, fast, minimalist Zsh plugin management function in <20 lines of code.
#
# Usage:
# ZPLUGINDIR=${ZDOTDIR:-~}/plugins
# source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh
# repos=(
#   # Regular plugins, always updated
#   'zsh-users/zsh-completions'
#   'ajeetdsouza/zoxide'
#
#   # Plugins pinned to a particular SHA
#   'zsh-users/zsh-syntax-highlighting@5eb677bb0fa9a3e60f0eff031dc13926e093df92'
#   'zsh-users/zsh-autosuggestions@85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5'
#   'zsh-users/zsh-history-substring-search@87ce96b1862928d84b1afe7c173316614b30e301'
# )
# plugin-load $repos
#

##? Clone a plugin using it's github repo and (optionally) commit sha, identify its init file, source it, and add it to your fpath.
function plugin-load {
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
    clone_args=(-q --depth 1 --recursive --shallow-submodules)
    if [[ -n "$commitsha" ]]; then
      clone_args+=(--no-checkout)
    fi
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
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf $initfiles[1] $initfile
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# where should we download your Zsh plugins?
#ZPLUGINDIR=$ZDOTDIR/plugins

##? Clone a plugin, identify its init file, source it, and add it to your fpath.
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

# make a github repo plugins list
plugins=(
  'sindresorhus/pure@5c2158096cd992ad73ae4b42aa43ee618383e092'
  'mattmc3/zman@8c41af514ae9ab6bc78078ed97c376edcfab929d'
  'rupa/z@d37a763a6a30e1b32766fecc3b8ffd6127f8a0fd'
  'rummik/zsh-tailf@92b04527b784a70a952efde20e6a7269278fb17d'
  'peterhurford/up.zsh@c8cc0d0edd6be2d01f467267e3ed385c386a0acb'
  'zsh-users/zsh-autosuggestions@85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5'
  'zsh-users/zsh-history-substring-search@87ce96b1862928d84b1afe7c173316614b30e301'

  # load these at hypersonic load speeds with zsh-defer
  'romkatv/zsh-defer@53a26e287fbbe2dcebb3aa1801546c6de32416fa'
  'olets/zsh-abbr@2fd354de4d21be6c91ad2ea71af08525f3e76b39'
  'zdharma-continuum/fast-syntax-highlighting@3d574ccf48804b10dca52625df13da5edae7f553'
)
plugin-load $plugins

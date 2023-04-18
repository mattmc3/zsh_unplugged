# zsh_unplugged - Tiny, simple, ultra-fast, micro plugin management functionality.
#                 See https://github.com/mattmc3/zsh_unplugged
# Usage:
# source /path/to/zsh_unplugged.zsh
# repos=(
#   zsh-users/zsh-syntax-highlighting
#   zsh-users/zsh-autosuggestions
#   zsh-users/zsh-history-substring-search
# )
# plugin-load $repos

# Set zsh_unplugged variables.
if [[ -n "$ZPLUGINDIR" ]]; then
  : ${ZUNPLUG_CUSTOM:=$ZPLUGINDIR}
  : ${ZUNPLUG_REPOS:=$ZPLUGINDIR}
else
  : ${ZUNPLUG_CUSTOM:=${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  : ${ZUNPLUG_REPOS:=${XDG_DATA_HOME:-$HOME/.local/share}/zsh_unplugged}
fi
typeset -gHa _zunplugopts=(extended_glob glob_dots no_monitor)

##? Clone zsh plugins in parallel.
function plugin-clone {
  emulate -L zsh; setopt local_options $_zunplugopts
  local repo
  for repo in ${(u)@}; do
    [[ ! -d $ZUNPLUG_REPOS/$repo ]] || continue
    echo >&2 "Cloning $repo..."
    (
      command git clone -q --depth 1 --recursive --shallow-submodules \
        ${ZUNPLUG_GITURL:-https://github.com}/$repo $ZUNPLUG_REPOS/$repo
      plugin-compile $ZUNPLUG_REPOS/$repo
    ) &
  done
  wait
}

##? Load zsh plugins.
function plugin-load {
  source <(plugin-script $@)
}

##? Script loading of zsh plugins.
function plugin-script {
  emulate -L zsh; setopt local_options $_zunplugopts
  local repo plugin pluginfile defer=0
  local -Ua initpaths repos=()

  # Remove bare words and paths, then split/join to keep the user/repo part.
  for repo in ${${(M)@:#*/*}:#/*}; do
    repo=${(@j:/:)${(@s:/:)repo}[1,2]}
    [[ -e $ZUNPLUG_REPOS/$repo ]] || repos+=$repo
  done
  plugin-clone $repos

  for plugin in $@; do
    initpaths=(
      $ZUNPLUG_CUSTOM/${plugin}/*.{plugin.zsh,zsh,zsh-theme,sh}(N)
      $ZUNPLUG_REPOS/${plugin}/*.{plugin.zsh,zsh,zsh-theme,sh}(N)
      $ZUNPLUG_REPOS/$plugin(N)
      ${plugin}/*.{plugin.zsh,zsh,zsh-theme,sh}(N)
      ${plugin}(N)
    )
    (( $#initpaths )) || { echo >&2 "Plugin file not found '$plugin'." && continue }
    pluginfile=$initpaths[1]
    (( $defer )) && echo zsh-defer source $pluginfile || echo source $pluginfile
    [[ "$plugin:t" == zsh-defer ]] && defer=1
  done
}

##? Update plugins.
function plugin-update {
  emulate -L zsh; setopt local_options $_zunplugopts
  local repodir repo oldsha newsha
  for repodir in $ZUNPLUG_REPOS/**/.git(N/); do
    repodir=${repodir:A:h}
    repo=${repodir:h:t}/${repodir:t}
    echo "Updating $repo..."
    (
      oldsha=$(command git -C $repodir rev-parse --short HEAD)
      command git -C $repodir pull --quiet --ff --depth 1 --rebase --autostash
      newsha=$(command git -C $repodir rev-parse --short HEAD)
      [[ $oldsha == $newsha ]] || echo "Plugin updated: $repo ($oldsha -> $newsha)"
    ) &
  done
  wait
  plugin-compile
  echo "Update complete."
}

##? Compile plugins.
function plugin-compile {
  emulate -L zsh; setopt local_options $_zunplugopts
  autoload -Uz zrecompile
  local zfile
  for zfile in ${1:-ZUNPLUG_REPOS}/**/*.zsh{,-theme}(N); do
    [[ $zfile != */test-data/* ]] || continue
    zrecompile -pq "$zfile"
  done
}

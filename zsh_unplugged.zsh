# zsh_unplugged - Tiny, simple, ultra-fast, zsh micro plugin management
# Usage (see also https://github.com/mattmc3/zsh_unplugged):
# source /path/to/zsh_unplugged.zsh
# myplugins=( zsh-users/zsh-autosuggestions ... )
# plugin-load $myplugins

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
  local repo repodir
  for repo in ${(u)@}; do
    repodir=$ZUNPLUG_REPOS/${repo:t}
    [[ ! -d $repodir ]] || continue
    echo "Cloning $repo..."
    (
      command git clone -q --depth 1 --recursive --shallow-submodules \
        ${ZUNPLUG_GITURL:-https://github.com}/$repo $repodir
      plugin-compile $repodir
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
  plugin-clone $repos >&2

  for plugin in $@; do
    [[ $plugin == /* ]] || plugin=${plugin#*/}
    initpaths=(
      {$ZUNPLUG_CUSTOM,$ZUNPLUG_REPOS}/${plugin}/${plugin:t}.{plugin.zsh,zsh-theme,zsh,sh}(N)
      {$ZUNPLUG_CUSTOM,$ZUNPLUG_REPOS}/${plugin}/*.{plugin.zsh,zsh-theme,zsh,sh}(N)
      $ZUNPLUG_REPOS/$plugin(N)
      ${plugin}/*.{plugin.zsh,zsh-theme,zsh,sh}(N)
      ${plugin}(N)
    )
    (( $#initpaths )) || { echo >&2 "Plugin file not found '$plugin'." && continue }
    pluginfile=$initpaths[1]
    echo "fpath+=$pluginfile:h"
    (( $defer )) && echo zsh-defer source $pluginfile || echo source $pluginfile
    [[ "$plugin:t" == zsh-defer ]] && defer=1
  done
}

##? Update plugins.
function plugin-update {
  emulate -L zsh; setopt local_options $_zunplugopts
  local repodir oldsha newsha
  for repodir in $ZUNPLUG_REPOS/**/.git(N/); do
    repodir=${repodir:A:h}
    echo "Updating ${repodir:t}..."
    (
      oldsha=$(command git -C $repodir rev-parse --short HEAD)
      command git -C $repodir pull --quiet --ff --depth 1 --rebase --autostash
      newsha=$(command git -C $repodir rev-parse --short HEAD)
      [[ $oldsha == $newsha ]] || echo "Plugin updated: $repodir:t ($oldsha -> $newsha)"
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

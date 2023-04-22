# zsh_unplugged - Micro zsh plugin management functions
# Usage: https://github.com/mattmc3/zsh_unplugged

# Set zsh_unplugged variables.
: ${ZUNPLUG_HOME:=${ZPLUGINDIR:-${XDG_DATA_HOME:-~/.local/share}/zsh_unplugged}}
: ${ZUNPLUG_CUSTOM:=${ZPLUGINDIR:-${ZSH_CUSTOM:-${ZDOTDIR:-~/.config/zsh}}/plugins}}
typeset -gHa _zunplugopts=(extended_glob glob_dots no_monitor)

##? Clone zsh plugins in parallel.
function plugin-clone {
  emulate -L zsh; setopt local_options $_zunplugopts
  local repo repodir
  for repo in ${(u)@}; do
    [[ ${ZUNPLUG_SHORTEN:-1} -eq 1 ]] && repodir=${repo:t} || repodir=$repo
    repodir=$ZUNPLUG_HOME/$repodir
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

  # Remove bare words and paths, then split/join to keep the 2-part user/repo form.
  for repo in ${${(M)@:#*/*}:#/*}; do
    repo=${(@j:/:)${(@s:/:)repo}[1,2]}
    [[ -e $ZUNPLUG_HOME/$repo ]] || repos+=$repo
  done
  plugin-clone $repos >&2

  for plugin in $@; do
    [[ ${ZUNPLUG_SHORTEN:-1} -eq 1 ]] && [[ $plugin != /* ]] && plugin=${plugin#*/}
    initpaths=(
      {$ZUNPLUG_CUSTOM,$ZUNPLUG_HOME}/${plugin}/${plugin:t}.{plugin.zsh,zsh-theme,zsh,sh}(N)
      {$ZUNPLUG_CUSTOM,$ZUNPLUG_HOME}/${plugin}/*.{plugin.zsh,zsh-theme,zsh,sh}(N)
      $ZUNPLUG_HOME/$plugin(N)
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
  for repodir in $ZUNPLUG_HOME/**/.git(N/); do
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
  for zfile in ${1:-ZUNPLUG_HOME}/**/*.zsh{,-theme}(N); do
    [[ $zfile != */test-data/* ]] || continue
    zrecompile -pq "$zfile"
  done
}

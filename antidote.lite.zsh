# antidote.lite - a micro zsh plugin manager based on antidote and zsh_unplugged.
# author:  mattmc3
# home:    https://github.com/mattmc3/zsh_unplugged
#          https://github.com/mattmc3/antidote
# license: https://unlicense.org
# usage:   plugin-load $myplugins
# version: 0.0.2

# Set variables.
: ${ANTIDOTE_LITE_HOME:=${XDG_CACHE_HOME:-~/.cache}/antidote.lite}
typeset -gHa _alite_zopts=(extended_glob glob_dots no_monitor)

##? Clone zsh plugins in parallel.
function plugin-clone {
  emulate -L zsh; setopt local_options $_alite_zopts
  local repo plugdir initfile initfiles=()

  # Remove bare words ${(M)@:#*/*} and paths with leading slash ${@:#/*}.
  # Then split/join to keep the 2-part user/repo form to bulk-clone repos.
  local -Ua repos
  for repo in ${${(M)@:#*/*}:#/*}; do
    repo=${(@j:/:)${(@s:/:)repo}[1,2]}
    [[ -e $ANTIDOTE_LITE_HOME/$repo ]] || repos+=$repo
  done

  for repo in $repos; do
    plugdir=$ANTIDOTE_LITE_HOME/$repo
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      (
        command git clone -q --depth 1 --recursive --shallow-submodules \
          ${ANTIDOTE_LITE_GITURL:-https://github.com/}$repo $plugdir
        if [[ ! -e $initfile ]]; then
          initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
          (( $#initfiles )) && ln -sf $initfiles[1] $initfile
        fi
        if [[ $repo == sorin-ionescu/prezto ]]; then
          for init in $plugdir/modules/*/init.zsh; do
            ln -sf $init $init:h/${init:h:t}.plugin.zsh
          done
        fi
        plugin-compile $plugdir
      ) &
    fi
  done
  wait
}

##? Load zsh plugins.
function plugin-load {
  source <(plugin-script $@)
}

##? Script loading of zsh plugins.
function plugin-script {
  emulate -L zsh; setopt local_options $_alite_zopts

  # parse args
  local kind=zsh  # kind=path,fpath,zsh
  while (( $# )); do
    case $1 in
      -k|--kind)  shift; kind=$1 ;;
      -*)         echo >&2 "Invalid argument '$1'." && return 2 ;;
      *)          break ;;
    esac
    shift
  done

  local plugdir initfile defer=0
  for plugdir in $@; do
    [[ $plugdir = /* ]] || plugdir=$ANTIDOTE_LITE_HOME/$plugdir
    if [[ $kind == path ]]; then
      echo "path=(\$path $plugdir)"
    elif [[ $kind == fpath ]]; then
      echo "fpath=(\$fpath $plugdir)"
    else
      echo "fpath=(\$fpath $plugdir)"
      if [[ -d $plugdir ]]; then
        initfile=$plugdir/${plugdir:t}.plugin.zsh
      else
        initfile=$plugdir
      fi
      (( $defer )) && printf '%s ' 'zsh-defer'
      echo "source $initfile"
      [[ "$plugdir:t" == zsh-defer ]] && defer=1
    fi
  done
}

##? Update plugins.
function plugin-update {
  emulate -L zsh; setopt local_options $_alite_zopts
  local plugdir oldsha newsha
  for plugdir in $ANTIDOTE_LITE_HOME/*/*/.git(N/); do
    plugdir=${plugdir:A:h}
    echo "Updating ${plugdir:h:t}/${plugdir:t}..."
    (
      oldsha=$(command git -C $plugdir rev-parse --short HEAD)
      command git -C $plugdir pull --quiet --ff --depth 1 --rebase --autostash
      newsha=$(command git -C $plugdir rev-parse --short HEAD)
      [[ $oldsha == $newsha ]] || echo "Plugin updated: $plugdir:t ($oldsha -> $newsha)"
    ) &
  done
  wait
  plugin-compile
  echo "Update complete."
}

##? Compile plugins.
function plugin-compile {
  emulate -L zsh; setopt local_options $_alite_zopts
  autoload -Uz zrecompile
  local zfile
  for zfile in ${1:-ANTIDOTE_LITE_HOME}/**/*.zsh{,-theme}(N); do
    [[ $zfile != */test-data/* ]] || continue
    zrecompile -pq "$zfile"
  done
}

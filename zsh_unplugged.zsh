#
# zsh_unplugged - https://github.com/mattmc3/zsh_unplugged
#
# Simple, ultra-fast, minimalist Zsh plugin management functions.
#
# Usage:
# source ${ZDOTDIR:-~}/zsh_unplugged.zsh
# repos=(
#   zsh-users/zsh-syntax-highlighting
#   zsh-users/zsh-autosuggestions
#   zsh-users/zsh-history-substring-search
# )
# plugin-load $repos
#

# Set the plugin destination.
: ${ZPLUGINDIR:=${ZDOTDIR:-$HOME/.config/zsh}/plugins}
autoload -Uz zrecompile

##? Clone zsh plugins in parallel and ensure proper plugin init files exist.
function plugin-clone {
  emulate -L zsh
  setopt local_options no_monitor
  local repo repodir

  for repo in ${(u)@}; do
    repodir=$ZPLUGINDIR/${repo:t}
    [[ ! -d $repodir ]] || continue
    echo "Cloning $repo..."
    (
      command git clone -q --depth 1 --recursive --shallow-submodules \
        ${ZPLUGIN_GITURL:-https://github.com}/$repo $repodir
      local initfile=$repodir/${repo:t}.plugin.zsh
      if [[ ! -e $initfile ]]; then
        local -a initfiles=($repodir/*.{plugin.,}{z,}sh{-theme,}(N))
        (( $#initfiles )) && ln -sf $initfiles[1] $initfile
      fi
      plugin-compile $repodir
    ) &
  done
  wait
}

##? Load zsh plugins.
function plugin-load {
  local plugin pluginfile
  local -a repos initpaths

  # repos are in the form user/repo. They contain a slash, but don't start with one.
  repos=(${${(M)@:#*/*}:#/*})
  plugin-clone $repos

  for plugin in $@; do
    if [[ $plugin == /* ]]; then
      initpaths=(
        $plugin/${plugin:t}.plugin.zsh(N)
        $plugin/*.{plugin.,}{z,}sh{-theme,}(N)
        $plugin(N)
      )
    else
      pluginfile=${plugin:t}/${plugin:t}.plugin.zsh
      initpaths=(
        $ZPLUGINDIR/${pluginfile}(N)
        ${ZDOTDIR:-$HOME/.config/zsh}/plugins/${pluginfile}(N)
        $ZSH_CUSTOM/plugins/${pluginfile}(N)
      )
    fi

    (( $#initpaths )) || { echo >&2 "Plugin not found '$plugin'."; continue }
    pluginfile=$initpaths[1]
    fpath+=($pluginfile:h)
    (( $+functions[zsh-defer] )) && zsh-defer . $pluginfile || . $pluginfile
  done
}

##? Update plugins.
function plugin-update {
  emulate -L zsh
  setopt local_options extended_glob glob_dots no_monitor
  local repodir
  for repodir in $ZPLUGINDIR/**/.git(N/); do
    local url=$(git -C ${repodir:A:h} config remote.origin.url)
    echo "Updating ${url:h:t}/${url:t}..."
    command git -C ${repodir:A:h} pull --quiet --ff --depth 1 --rebase --autostash &
  done
  wait
  plugin-compile
  echo "Update complete."
}

##? Compile plugins.
function plugin-compile {
  local zfile
  for zfile in ${1:-ZPLUGINDIR}/**/*.zsh{,-theme}(N); do
    [[ $zfile != */test-data/* ]] || continue
    zrecompile -pq "$zfile"
  done
}

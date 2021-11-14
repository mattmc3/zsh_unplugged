# unplugged: https://github.com/mattmc3/zsh_unplugged

# clone a plugin, find an init.zsh, source it, and add it to your fpath
function plugin-load () {
  local giturl="$1"
  local plugin_name=${${giturl##*/}%.git}
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}/$plugin_name"

  # clone if the plugin isn't there already
  if [[ ! -d $plugindir ]]; then
    command git clone --depth 1 --recursive --shallow-submodules $giturl $plugindir
    if [[ $? -ne 0 ]]; then
      echo "plugin-load: git clone failed for: $giturl" >&2 && return 1
    fi
  fi

  # symlink an init.zsh if there isn't one so the plugin is easy to source
  if [[ ! -f $plugindir/init.zsh ]]; then
    local initfiles=(
      # look for specific files first
      $plugindir/$plugin_name.plugin.zsh(N)
      $plugindir/$plugin_name.zsh(N)
      $plugindir/$plugin_name(N)
      $plugindir/$plugin_name.zsh-theme(N)
      # then do more aggressive globbing
      $plugindir/*.plugin.zsh(N)
      $plugindir/*.zsh(N)
      $plugindir/*.zsh-theme(N)
      $plugindir/*.sh(N)
    )
    if [[ ${#initfiles[@]} -eq 0 ]]; then
      echo "plugin-load: no plugin init file found" >&2 && return 1
    fi
    command ln -s ${initfiles[1]} $plugindir/init.zsh
  fi

  # source the plugin
  source $plugindir/init.zsh

  # modify fpath
  fpath+=$plugindir
  [[ -d $plugindir/functions ]] && fpath+=$plugindir/functions
}

# if you want to compile your plugins you may see performance gains
function plugin-compile () {
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}"
  autoload -U zrecompile
  local f
  for f in $plugindir/**/*.zsh{,-theme}(N); do
    zrecompile -pq "$f"
  done
}

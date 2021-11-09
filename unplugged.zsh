# unplugged: https://github.com/mattmc3/zsh_unplugged

# what if you don't really need a "Zsh plugin manager" after all???
function plugin-clone () {
  emulate -L zsh; setopt local_options null_glob extended_glob
  local giturl="$1"
  local plugin_name=${${1##*/}%.git}
  local plugin_subdir="${ZPLUGINDIR:-$HOME/.zsh/plugins}/$plugin_name"

  # clone if the plugin isn't there already
  if [[ ! -d $plugin_subdir ]]; then
    command git clone --depth 1 --recursive --shallow-submodules $giturl $plugin_subdir
    [[ $? -eq 0 ]] || { >&2 echo "plugin-clone: git clone failed; $1" && return 1 }
  fi

  # symlink an init.zsh if there isn't one so the plugin is easy to source
  if [[ ! -f $plugin_subdir/init.zsh ]]; then
    local initfiles=(
      # look for specific files first
      $plugin_subdir/$plugin_name.plugin.zsh(N)
      $plugin_subdir/$plugin_name.zsh(N)
      $plugin_subdir/$plugin_name(N)
      $plugin_subdir/$plugin_name.zsh-theme(N)
      # then do more aggressive globbing
      $plugin_subdir/*.plugin.zsh(N)
      $plugin_subdir/*.zsh(N)
      $plugin_subdir/*.zsh-theme(N)
      $plugin_subdir/*.sh(N)
    )
    [[ ${#initfiles[@]} -gt 0 ]] || { >&2 echo "plugin-clone: no plugin init file found" && return 1 }
    command ln -s ${initfiles[1]} $plugin_subdir/init.zsh
  fi
}

# updating your plugins is as simple as doing a git pull
function plugin-update () {
  emulate -L zsh; setopt local_options null_glob extended_glob
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}"
  for d in $plugindir/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

# if you want to compile your plugins you may see performance gains
function plugin-compile () {
  emulate -L zsh; setopt local_options null_glob extended_glob
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}"
  autoload -U zrecompile
  local f
  for f in $plugindir/**/*.zsh{,-theme}; do
    zrecompile -pq "$f"
  done
}

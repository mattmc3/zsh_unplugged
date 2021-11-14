# ...standard oh-my-zsh boilerplate goes here...

# use a clone-only function
function plugin-clone () {
  local giturl="$1"
  local plugin_name=${${giturl##*/}%.git}
  local plugindir="$ZSH_CUSTOM/plugins/$plugin_name"

  # clone if the plugin isn't there already
  if [[ ! -d $plugindir ]]; then
    command git clone --depth 1 --recursive --shallow-submodules $giturl $plugindir
    if [[ $? -ne 0 ]]; then
      echo "plugin-clone: git clone failed for: $giturl" >&2 && return 1
    fi
  fi

  # symlink a {plugin-name}.plugin.zsh file if there isn't one so OMZ knows
  # how to load this plugin
  if [[ ! -f $plugindir/$plugin_name.plugin.zsh ]] &&
     [[ ! -f $plugindir/$plugin_name.zsh-theme ]]; then
    local initfiles=(
      # look for specific files first
      $plugindir/$plugin_name.zsh(N)
      $plugindir/$plugin_name(N)
      # then do more aggressive globbing
      $plugindir/*.plugin.zsh(N)
      $plugindir/*.zsh-theme(N)
      $plugindir/*.zsh(N)
      $plugindir/*.sh(N)
    )
    if [[ ${#initfiles[@]} -eq 0 ]]; then
      echo "plugin-clone: no plugin init file found" >&2 && return 1
    fi
    command ln -s ${initfiles[1]} $plugindir/$plugin_name.plugin.zsh
  fi

  # no need to source the plugin because OMZ will do that via
  # its plugins=(...) list
}

# clone your external plugins if needed
external_plugins=(
  zsh-users/zsh-autosuggestions
  marlonrichert/zsh-hist
  zsh-users/zsh-syntax-highlighting
)
for repo in $external_plugins; do
  if [[ ! -d $ZSH_CUSTOM/plugins/${repo:t} ]]; then
    git clone https://github.com/${repo} $ZSH_CUSTOM/plugins/${repo:t}
  fi
done

# add your external plugins to your OMZ plugins list
plugins=(
  # OMZ plugins
  # git, etc...
  # external plugins
  zsh-hist
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

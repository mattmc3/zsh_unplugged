# ...standard oh-my-zsh boilerplate goes here...
ZSH=${ZSH:-~/.oh-my-zsh}
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}

# use a clone-only function because oh-my-zsh handles the load
function omz-plugin-clone() {
  # clone plugin if not found
  local repo plugin_dir initfile initfiles
  for repo in $@; do
    plugin_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/${repo:t}
    initfile=$plugin_dir/${repo:t}.plugin.zsh
    [[ -d $plugin_dir ]] \
      || git clone --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
    if [[ ! -e $initfile ]]; then
      initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh(N))
      [[ ${#initfiles[@]} -gt 0 ]] || { echo >&2 "Plugin has no init file '$repo'" && continue }
      ln -s "${initfiles[1]}" "$initfile"
    fi
  done
}

# clone your external plugins if needed
external_plugins=(
  zsh-users/zsh-autosuggestions
  marlonrichert/zsh-hist
  zsh-users/zsh-syntax-highlighting
)
omz-plugin-clone $external_plugins

# set your normal oh-my-zsh plugins
plugins=(
  git
  magic-enter
)

# now add your external plugins to your OMZ plugins list
plugins+=(${external_plugins:t})

# then source oh-my-zsh
source $ZSH/oh-my-zsh.sh

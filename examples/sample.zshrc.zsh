# where should we download your Zsh plugins?
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-~/.config/zsh}/plugins}

# declare a simple plugin-load function
function plugin-load() {
  # clone and source plugins, using zsh-defer if it exists
  local repo plugin_name plugin_dir initfile initfiles
  for repo in $@; do
    plugin_name=${repo:t}
    plugin_dir=$ZPLUGINDIR/$plugin_name
    initfile=$plugin_dir/$plugin_name.plugin.zsh
    [[ -d $plugin_dir ]] \
      || git clone --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
    if [[ ! -e $initfile ]]; then
      initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh(N))
      [[ ${#initfiles[@]} -gt 0 ]] || { echo >&2 "Plugin has no init file '$repo'." && continue }
      ln -s "${initfiles[1]}" "$initfile"
    fi
    if (( $+functions[zsh-defer] )); then
      zsh-defer source $initfile
    else
      source $initfile
    fi
  done
}

# make a github repo plugins list
plugins=(
  # load these first
  zshzoo/zshrc.d
  romkatv/zsh-defer

  # general plugins
  zshzoo/setopts
  zshzoo/history
  zshzoo/keybindings
  zshzoo/zstyle-completions
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  mattmc3/zman
  olets/zsh-abbr
  zshzoo/copier
  zshzoo/macos
  zshzoo/prj
  zshzoo/magic-enter
  zshzoo/zfishcmds
  zshzoo/termtitle
  rupa/z
  rummik/zsh-tailf
  peterhurford/up.zsh

  # prompts
  sindresorhus/pure

  # load these last
  zshzoo/compinit
  zdharma-continuum/fast-syntax-highlighting
)
plugin-load $plugins

# where should we download your Zsh plugins?
#ZPLUGINDIR=$ZDOTDIR/plugins

# declare a simple plugin-load function
function plugin-load() {
  local repo plugin_name plugin_dir initfile initfiles
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-~/.config/zsh}/plugins}
  for repo in $@; do
    plugin_name=${repo:t}
    plugin_dir=$ZPLUGINDIR/$plugin_name
    initfile=$plugin_dir/$plugin_name.plugin.zsh
    if [[ ! -d $plugin_dir ]]; then
      echo "Cloning $repo"
      git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      [[ ${#initfiles[@]} -gt 0 ]] || { echo >&2 "Plugin has no init file '$repo'." && continue }
      ln -s "${initfiles[1]}" "$initfile"
    fi
    fpath+=$plugin_dir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# make a github repo plugins list
plugins=(
  # load these first
  zshzoo/zshrc.d
  sindresorhus/pure
  romkatv/zsh-defer

  # other plugins, all at hypersonic load speeds with zsh-defer
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

  # load these last
  zshzoo/compinit
  zdharma-continuum/fast-syntax-highlighting
)
plugin-load $plugins

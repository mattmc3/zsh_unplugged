# zunplugged: https://github.com/mattmc3/zsh_unplugged
# a simple, ultra-fast plugin handler

function plugin-load() {
  # clone a plugin, identify the plugin's init file, source it (with defer if possible),
  # and add it to your fpath
  local repo plugin_name plugin_dir initfile initfiles
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-~/.config/zsh}/plugins}
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
    fpath+=$plugin_dir
    if (( $+functions[zsh-defer] )); then
      zsh-defer source $initfile
    else
      source $initfile
    fi
  done
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

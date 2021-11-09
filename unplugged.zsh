# unplugged: https://github.com/mattmc3/zsh_unplugged

# what if you didn't really need a "Zsh plugin manager" after all???
function plugin-clone () {
    local giturl="$1"
    local plugin_name=${${1##*/}%.git}
    local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}/$plugin_name"

    # clone if the plugin isn't there already
    [[ ! -d $plugindir ]] || return 1
    command git clone --depth 1 --recursive --shallow-submodules $giturl $plugindir
    [[ $? -eq 0 ]] || { >&2 echo "plugin-clone: git clone failed; $1" && return 1 }

    # symlink an init.zsh if there isn't one so the plugin is easy to source
    [[ ! -f $plugindir/init.zsh ]] || return
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
    [[ ${#initfiles[@]} -gt 0 ]] || { >&2 echo "plugin-clone: no plugin init file found" && return 1 }
    command ln -s ${initfiles[1]} $plugindir/init.zsh
}

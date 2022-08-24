#!/usr/bin/env zsh
0=${(%):-%x}
BASEDIR=${0:A:h:h}
source $ZTAP_HOME/ztap3.zsh
ztap_header "${0:t:r}"

ZPLUGINDIR=$(mktemp -d -t ztap)

typeset -gA plugins
# note, don't test zsh-defer here...
plugins=(
  # zsh-users core plugins
  zsh-users/zsh-syntax-highlighting  _zsh_highlight
  zsh-users/zsh-autosuggestions      _zsh_autosuggest_suggest

  # popular themes/prompts
  sindresorhus/pure      prompt_pure_setup
  romkatv/powerlevel10k  _p9k_init_locale

  # non-standard-conforming plugins
  peterhurford/up.zsh    up
  rummik/zsh-tailf       tailf
  rupa/z                 _z
)

source $BASEDIR/zsh_unplugged.plugin.zsh

for repo in ${(ko)plugins}; do
  func=$plugins[$repo]
  plugin_name=${repo:t}
  @echo "--- $plugin_name ---"
  @test "$plugin_name function does not exist" "$+functions[$func]" -eq 0
  plugin-load $repo &>/dev/null
  @test "$plugin_name init file exists" -e "$ZPLUGINDIR/$plugin_name/$plugin_name.plugin.zsh"
  @test "$plugin_name function exists" "$+functions[$func]" -eq 1
done

if [[ -d $ZPLUGINDIR ]] && [[ $ZPLUGINDIR = *ztap* ]]; then
  rm -rf $ZPLUGINDIR
fi

ztap_footer

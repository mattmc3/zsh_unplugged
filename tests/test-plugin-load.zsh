#!/usr/bin/env zsh
0=${(%):-%x}
BASEDIR=${0:A:h:h}
source $ZTAP_HOME/ztap3.zsh
ztap_header "${0:t:r}"

ZPLUGINDIR=$(mktemp -d -t ztap)

@test "plugin-load function does not exist" "$+functions[plugin-load]" -eq 0
source $BASEDIR/zsh_unplugged.plugin.zsh
@test "zunplugged sourced successfully" $? -eq 0
@test "plugin-load function exists" "$+functions[plugin-load]" -eq 1

@test "zsh-defer function does not exist" "$+functions[zsh-defer]" -eq 0
plugin-load romkatv/zsh-defer &>/dev/null
@test "plugin-load succeeded with exit code 0" $? -eq 0
@test "zsh-defer function exists" "$+functions[zsh-defer]" -eq 1

zwcfiles=($ZPLUGINDIR/**/*.zwc(N))
@test "no .zwc files exist" "${#zwcfiles[@]}" -eq 0
plugin-compile &>/dev/null
@test "plugin-compile succeeded with exit code 0" $? -eq 0
zwcfiles=($ZPLUGINDIR/**/*.zwc(N))
@test ".zwc files were created" "${#zwcfiles[@]}" -gt 0

if [[ -d $ZPLUGINDIR ]] && [[ $ZPLUGINDIR = *ztap* ]]; then
  rm -rf $ZPLUGINDIR
fi

ztap_footer

@echo "=== ${0:t:r} ==="
PROJECT_HOME=${0:a:h:h}
ZPLUGINDIR=$(mktemp -d -t ztap)

@test "plugin-load function does not exist" "$+functions[plugin-load]" -eq 0
source $PROJECT_HOME/zunplugged.zsh
@test "zunplugged sourced successfully" $? -eq 0
@test "plugin-load function exists" "$+functions[plugin-load]" -eq 1

if [[ -d $ZPLUGINDIR ]] && [[ $ZPLUGINDIR = *ztap* ]]; then
  rm -rf $ZPLUGINDIR
fi

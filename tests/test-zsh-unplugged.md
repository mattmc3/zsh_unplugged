# test-zsh-unplugged

## Setup

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

## Test

plugin-load function does not exist
```zsh
% echo $+functions[plugin-load]
0
%
```

zsh_unplugged sources successfully
```zsh
% source zsh_unplugged.zsh #=> --exit 0
% echo $+functions[plugin-load]
1
%
```

zsh_unplugged clones a plugin
```zsh
% echo $+functions[zsh-defer]
0
% plugin-script romkatv/zsh-defer | substenv ZUNPLUG_REPOS
source $ZUNPLUG_REPOS/romkatv/zsh-defer/zsh-defer.plugin.zsh
% plugin-load romkatv/zsh-defer
% echo $+functions[zsh-defer]
1
%
```

```zsh
% echo $ZUNPLUG_REPOS | substenv HOME
$HOME/.local/share/zsh_unplugged
% echo $ZUNPLUG_CUSTOM | substenv ZDOTDIR
$ZDOTDIR/plugins
%
```

## Teardown

```zsh
% t_teardown
%
```

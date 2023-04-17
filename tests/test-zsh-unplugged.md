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
% plugin-load romkatv/zsh-defer
Cloning romkatv/zsh-defer...
% echo $+functions[zsh-defer]
1
%
```

```zsh
% echo $ZPLUGINDIR | substenv
$ZDOTDIR/plugins
%
```

## Teardown

```zsh
% t_teardown
%
```

# Load zstyles. This is where you could put Prezto customizations.
[[ -f $ZDOTDIR/.zstyles ]] && source $ZDOTDIR/.zstyles

# Clone zsh_unplugged and use it as a plugin manager.
[[ -d $ZDOTDIR/.unplugged ]] ||
  git clone git@github.com:mattmc3/zsh_unplugged $ZDOTDIR/.unplugged
source $ZDOTDIR/.unplugged/unplugged.zsh
#ZPLUGINDIR=${XDG_DATA_HOME:=~/.local/share}/zsh_unplugged

# Get frameworks
frameworks=(
  ohmyzsh/ohmyzsh
  sorin-ionescu/prezto
)
plugin-clone $frameworks

# framework vars
OMZLIB=$ZPLUGINDIR/ohmyzsh/lib
OMZ=$ZPLUGINDIR/ohmyzsh/plugins
PREZTO=$ZPLUGINDIR/prezto/modules
PREZTORC=$ZPLUGINDIR/prezto/runcoms

# load plugins
plugins=(
  # remote plugins
  mattmc3/zman
  zshzoo/macos
  agkozak/zsh-z

  # framework plugins
  $OMZLIB/clipboard.zsh
  $OMZ/copyfile
  $OMZ/copypath
  $OMZ/copybuffer
  $OMZ/magic-enter
  $OMZ/fancy-ctrl-z
  $OMZ/extract
  $PREZTORC/zprofile
  $PREZTO/terminal
  $PREZTO/editor
  $PREZTO/history
  $PREZTO/directory

  # your local plugins in $ZDOTDIR/plugins
  # my_plugin
  # python

  # prompt
  sindresorhus/pure

  # do these last
  zsh-users/zsh-completions
  $PREZTO/completion

  # deferred
  romkatv/zsh-defer
  olets/zsh-abbr
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
)
plugin-load $plugins

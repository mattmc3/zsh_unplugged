# .zshrc

# Clone zsh_unplugged and use it as a micro plugin manager.
[[ -d $ZDOTDIR/.unplugged ]] ||
  git clone https://github.com/mattmc3/zsh_unplugged $ZDOTDIR/.unplugged
source $ZDOTDIR/.unplugged/zsh_unplugged.zsh

# clone-only plugins
plugin-clone romkatv/zsh-bench
path+=$ZPLUGINDIR/romkatv/zsh-bench

# load plugins
plugins=(
  # Uncomment to load your custom zstyles.
  # $ZDOTDIR/.zpreztorc
  # $ZDOTDIR/.zstyles

  # regular plugins
  mattmc3/zman
  zshzoo/macos
  agkozak/zsh-z

  # oh-my-zsh plugins
  ohmyzsh/ohmyzsh/lib/clipboard.zsh
  ohmyzsh/ohmyzsh/plugins/copyfile
  ohmyzsh/ohmyzsh/plugins/copypath
  ohmyzsh/ohmyzsh/plugins/copybuffer
  ohmyzsh/ohmyzsh/plugins/magic-enter
  ohmyzsh/ohmyzsh/plugins/fancy-ctrl-z
  ohmyzsh/ohmyzsh/plugins/extract

  # prezto modules
  sorin-ionescu/prezto/runcoms/zprofile
  sorin-ionescu/prezto/modules/terminal
  sorin-ionescu/prezto/modules/editor
  sorin-ionescu/prezto/modules/history
  sorin-ionescu/prezto/modules/directory

  # Uncomment to use your local plugins
  # Put these in $ZDOTDIR/plugins
  # my_plugin
  # python

  # prompt
  sindresorhus/pure

  # do completions
  zsh-users/zsh-completions
  sorin-ionescu/prezto/modules/completion

  # Deferred plugins may speed up your load times even more.
  # Once you load romkatv/zsh-defer, everything after gets deferred.
  romkatv/zsh-defer
  olets/zsh-abbr
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
)
plugin-load $plugins

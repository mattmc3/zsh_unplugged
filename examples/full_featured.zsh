# .zshrc

# Clone zsh_unplugged and use it as a micro plugin manager.
[[ -d $ZDOTDIR/.unplugged ]] ||
  git clone https://github.com/mattmc3/zsh_unplugged $ZDOTDIR/.unplugged
source $ZDOTDIR/.unplugged/zsh_unplugged.zsh

# clone-only plugins
plugin-clone 'romkatv/zsh-bench@d7f9f821688bdff9365e630a8aaeba1fd90499b1'
path+=$ZPLUGINDIR/romkatv/zsh-bench

# load plugins
plugins=(
  # Uncomment to load your custom zstyles.
  # $ZDOTDIR/.zpreztorc
  # $ZDOTDIR/.zstyles

  # regular plugins
  'mattmc3/zman@8c41af514ae9ab6bc78078ed97c376edcfab929d'
  'zshzoo/macos@440e565ef0f31c4aaa51f720dffc652601155eed'
  'agkozak/zsh-z@cf9225feebfae55e557e103e95ce20eca5eff270'

  # oh-my-zsh plugins
  'ohmyzsh/ohmyzsh/lib/clipboard.zsh@a6beb0f5958e935d33b0edb6d4470c3d7c4e8917'
  ohmyzsh/ohmyzsh/plugins/copyfile
  ohmyzsh/ohmyzsh/plugins/copypath
  ohmyzsh/ohmyzsh/plugins/copybuffer
  ohmyzsh/ohmyzsh/plugins/magic-enter
  ohmyzsh/ohmyzsh/plugins/fancy-ctrl-z
  ohmyzsh/ohmyzsh/plugins/extract

  # prezto modules
  'sorin-ionescu/prezto/runcoms/zprofile@af383940911fc3192beb6e0fd2566c52bd1ea9ba'
  sorin-ionescu/prezto/modules/terminal
  sorin-ionescu/prezto/modules/editor
  sorin-ionescu/prezto/modules/history
  sorin-ionescu/prezto/modules/directory

  # Uncomment to use your local plugins
  # Put these in $ZDOTDIR/plugins
  # my_plugin
  # python

  # prompt
  'sindresorhus/pure@5c2158096cd992ad73ae4b42aa43ee618383e092'

  # do completions
  'zsh-users/zsh-completions@5f24f3bc42c8a1ccbfa4260a3546590ae24fc843'
  sorin-ionescu/prezto/modules/completion

  # Deferred plugins may speed up your load times even more.
  # Once you load romkatv/zsh-defer, everything after gets deferred.
  'romkatv/zsh-defer@53a26e287fbbe2dcebb3aa1801546c6de32416fa'
  'olets/zsh-abbr@2fd354de4d21be6c91ad2ea71af08525f3e76b39'
  'zdharma-continuum/fast-syntax-highlighting@3d574ccf48804b10dca52625df13da5edae7f553'
  'zsh-users/zsh-autosuggestions@85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5'
  'zsh-users/zsh-history-substring-search@87ce96b1862928d84b1afe7c173316614b30e301'
)
plugin-load $plugins

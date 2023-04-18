# prezto calls plugins 'contribs', so let's match that verbiage

# clone contribs and identify their init files
# let prezto source them later
function contrib-clone() {
  local repo plugin_name plugin_dir initfile initfiles=()
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for repo in $@; do
    plugin_name=${repo:t}
    plugin_dir=$ZPLUGINDIR/$plugin_name
    initfile=$plugin_dir/init.zsh
    if [[ ! -d $plugin_dir ]]; then
      echo "Cloning $repo"
      git clone -q --depth 1 --recursive --shallow-submodules \
        https://github.com/$repo $plugin_dir
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugin_dir/*.{plugin.zsh,zsh,sh,zsh-theme}(N))
      (( $#initfiles )) && ln -sf $initfiles[1] $initfile
    fi
  done
}

# put our plugins in a .zcontribs dir
ZPLUGINDIR=${ZDOTDIR:-~}/.zcontribs

contribs=(
  # prezto
  sorin-ionescu/prezto
  belak/prezto-contrib

  # 3rd party contribs
  joshskidmore/zsh-fzf-history-search
  mattmc3/zman
  peterhurford/up.zsh
  rummik/zsh-tailf
  rupa/z
  zdharma-continuum/fast-syntax-highlighting
)
contrib-clone $contribs

prezto_modules=(
  # zprezto built-ins
  autosuggestions
  environment
  terminal
  editor
  directory
  spectrum
  utility
  history-substring-search
  prompt
  git

  # belak/prezto-contrib
  clipboard
  elapsed-time

  # 3rd party contribs
  up.zsh
  zsh-tailf
  zsh-fzf-history-search
  z
  zman

  # load these last
  completion
  fast-syntax-highlighting
)

# this Prezto config section can go in .zpreztorc
# or you can keep it all in .zshrc if you don't want an extra Prezto file
zstyle ':prezto:load' pmodule $prezto_modules
zstyle ':prezto:load' pmodule-dirs $ZPLUGINDIR $ZPLUGINDIR/prezto-contrib
zstyle ':prezto:load' pmodule-allow-overrides 'yes'
zstyle ':prezto:module:prompt' theme 'sorin'
zstyle ':prezto:module:git:alias' skip 'yes'

# source prezto and let it load the contribs we cloned and added to modules
ZPREZTODIR=$ZPLUGINDIR/prezto
source $ZPREZTODIR/init.zsh

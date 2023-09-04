# .zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set Zsh options.
set extended_glob

# Setup vars similar to Oh My Zsh.
ZSH=${ZSH:-${ZDOTDIR:-$HOME/.config/zsh}}
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}

# Use antidote.lite - a Zsh micro plugin manager based on zsh_unplugged.
if [[ ! -e $ZSH/lib/antidote.lite.zsh ]]; then
  mkdir -p $ZSH/lib
  curl -fsSL -o $ZSH/lib/antidote.lite.zsh \
    https://raw.githubusercontent.com/mattmc3/zsh_unplugged/main/antidote.lite.zsh
fi

# Load any files in your lib directory.
for zlib in $ZSH/lib/*.zsh(N); source $zlib
unset zlib

# Make a list of util (path) plugins.
myutils=(
  romkatv/zsh-bench
)

# Make a list of prompt (fpath) plugins.
myprompts=(
  sindresorhus/pure
  romkatv/powerlevel10k
)

# Make a list of regular Zsh plugins.
# More great plugins can be found here: https://github.com/unixorn/awesome-zsh-plugins
myplugins=(
  # put anything you want in $ZSH_CUSTOM/plugins just like OMZ
  # git
  # python
  # etc

  # core plugins
  mattmc3/zephyr/plugins/color
  mattmc3/zephyr/plugins/editor
  mattmc3/zephyr/plugins/history
  mattmc3/zephyr/plugins/utility
  mattmc3/zephyr/plugins/prompt

  # oh-my-zsh plugins
  ohmyzsh/ohmyzsh/lib/clipboard.zsh
  ohmyzsh/ohmyzsh/plugins/colored-man-pages
  ohmyzsh/ohmyzsh/plugins/magic-enter

  # completions
  zsh-users/zsh-completions
  mattmc3/zephyr/plugins/completion

  # fish-like plugins
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
)

# Clone missing plugins from the lists, and then load them.
plugin-clone $myutils $myprompts $myplugins
plugin-load --kind path $myutils
plugin-load --kind fpath $myprompts
plugin-load $myplugins

# pick your prompt (options: pure, powerlevel10k, starship)
prompt powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.zsh/.p10k.zsh.
[[ ! -f ${ZDOTDIR:-$HOME}/.p10k.zsh ]] || source ${ZDOTDIR:-$HOME}/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

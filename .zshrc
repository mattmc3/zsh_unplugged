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

# load any files in your lib directory
for zlib in $ZSH/lib/*.zsh(N); source $zlib
unset zlib

# util (path) plugins
myutils=(
  romkatv/zsh-bench
)

# promt (fpath) plugins
myprompts=(
  sindresorhus/pure
  romkatv/powerlevel10k
)

# regular Zsh plugins
myplugins=(
  # put anything you want in $ZSH_CUSTOM/plugins just like OMZ
  # git
  # python
  # etc

  # core plugins
  mattmc3/zephyr/plugins/color
  mattmc3/zephyr/plugins/directory
  mattmc3/zephyr/plugins/editor
  mattmc3/zephyr/plugins/environment
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

# clone and load
plugin-clone $myplugins $myprompts $myutils
plugin-load --kind path $myutils
plugin-load --kind fpath $myprompts
plugin-load $myplugins

# pick your prompt (options: pure, powerlevel10k, starship)
prompt powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.zsh/.p10k.zsh.
[[ ! -f ${ZDOTDIR:-$HOME}/.p10k.zsh ]] || source ${ZDOTDIR:-$HOME}/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

#
# .zshrc - Run on interactive Zsh session.
#

# vars
myrepos=(
  mbadolato/iTerm2-Color-Schemes
)

myutils=(
  romkatv/zsh-bench
)

myprompts=(
  sindresorhus/pure
  romkatv/powerlevel10k
)

myplugins=(
  mattmc3/zfunctions
  mattmc3/zman
  rupa/z
  ohmyzsh/ohmyzsh/lib/clipboard.zsh
  ohmyzsh/ohmyzsh/plugins/copybuffer
  ohmyzsh/ohmyzsh/plugins/magic-enter
  ohmyzsh/ohmyzsh/plugins/fancy-ctrl-z
  belak/zsh-utils/editor
  belak/zsh-utils/history
  belak/zsh-utils/prompt
  belak/zsh-utils/utility
  belak/zsh-utils/completion

  # deferred
  romkatv/zsh-defer
  olets/zsh-abbr
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
)

# antidote.lite
source $ZDOTDIR/lib/antidote.lite.zsh
plugin-clone $myrepos $myutils $myprompts $myplugins
plugin-load --kind path $myutils
plugin-load --kind fpath $myprompts
plugin-load $myplugins

# prompt
prompt pure

# vim: ft=zsh sw=2 ts=2 et

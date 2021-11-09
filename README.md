# zsh_unplugged

🤔 perhaps you don't need a Zsh plugin manager after all...

TLDR? Click here to [skip to the code](#tada-the-code).

## :electric_plug: Zsh Plugin Managers

### :newspaper_roll: Current state

There are an embarassingly large number of Zsh plugin managers out there. Many of them
are abandonware, are no longer actively developed, are brand new without many users, or
don't have much reason to even exist other than as a novelty.

Here's a list of many (but probably not all) of them from [awesome-zsh-plugins]:

| Zsh Plugin Manager | Performance        | Current state                                   |
|--------------------|--------------------|-------------------------------------------------|
| [antibody]         | :rabbit2: fast     | :imp: Maintenance mode, no new features         |
| [antigen]          | :turtle: slow      | :imp: Maintenance mode, no new features         |
| [mzpm]             | :question: unknown | :hatching_chick: New                            |
| [pz]               | :rabbit2: fast     | :white_check_mark: Active                       |
| [sheldon]          | :question: unknown | :white_check_mark: Active                       |
| [tzpm]             | :question: unknown | :hatching_chick: New                            |
| [uz]               | :question: unknown | :hatching_chick: New                            |
| [zcomet]           | :rabbit2: fast     | :white_check_mark: Active                       |
| [zed]              | :question: unknown | :hatching_chick: New                            |
| [zgem]             | :question: unknown | :skull_and_crossbones: Abandonware              |
| [zgen]             | :rabbit2: fast     | :skull_and_crossbones: Abandonware              |
| [zgenom]           | :rabbit2: fast     | :white_check_mark: Active                       |
| [zinit-continuum]  | :rabbit2: fast     | :hatching_chick: New, possibly maintenance only |
| [zinit]            | :rabbit2: fast     | :cursing_face: Author deleted project           |
| [zit]              | :question: unknown | :imp: No recent commits                         |
| [znap]             | :rabbit2: fast     | :white_check_mark: Active                       |
| [zplug]            | :turtle: slow      | :skull_and_crossbones: Abandonware              |
| [zplugin][zinit]   | :rabbit2: fast     | :cursing_face: Renamed to zinit, author deleted |
| [zpm]              | :rabbit2: fast     | :white_check_mark: Active                       |
| [zr]               | :question: unknown | :imp: No recent commits                         |

Full disclosure, I'm even the author of one of these - [pz].

### :firecracker: The catalyst

A little while ago, the plugin manager I was using, [antibody], was deprecated.
The author even [went so far as to say](https://github.com/getantibody/antibody/tree/2ca7616ae78754c0ab70790229f5d19be42206e9):

> Most of the other plugin managers catch up on performance, thus keeping this does not make sense anymore.

Even more recently, a relatively well known and popular Zsh plugin manager, zinit, was
removed from GitHub entirely and without warning. In fact, the author
[deleted almost his entire body of work][zdharma-debacle].

Zinit was really popular because it was super fast, and the author promoted his projects
in multiple venues for many years. However, [zinit was complicated][zinit-docs-reddit],
and despite having prolific documentation, it was difficult to understand.

With the instablility in the Zsh plugin space, it got me wondering why I even use a
plugin manager at all.

### :bulb: The simple idea

When developing [pz], my goal was simple - make a plugin manager in a single Zsh file
that was fast, functional, and easy to understand. While [pz] is a great project, I
kept wondering if I could cut further from a single file to a single function.

Thus was born... **zsh_unplugged**.

This isn't a plugin manager - it's a way to perhaps once-and-for-all convince you that
you probably don't even need a Zsh plugin manager to begin with.

## :tada: The code

### :gear: The bare metal way

If you don't want to use a plugin manager at all, you can simply clone and source
plugins yourself manually:

```zsh
ZPLUGINDIR=$HOME/.zsh/plugins

if [[ ! -d $ZPLUGINDIR/zsh-autosuggestions ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZPLUGINDIR/zsh-autosuggestions
fi
if [[ ! -d $ZPLUGINDIR/zsh-history-substring-search ]]; then
  git clone https://github.com/zsh-users/zsh-history-substring-search $ZPLUGINDIR/zsh-history-substring-search
fi
if [[ ! -d $ZPLUGINDIR/z ]]; then
  git clone https://github.com/rupa/z $ZPLUGINDIR/z
fi

source $ZPLUGINDIR/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source $ZPLUGINDIR/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
source $ZPLUGINDIR/z/z.sh
```

This can get pretty verbose.

### :gemini: The `plugin-load` function

If we go one level of abstraction higher, we can use a simple function as the basis for
everything you need to use Zsh plugins:

```zsh
# clone your plugin, set up an init.zsh, source it, and add to your fpath
function plugin-load () {
  local giturl="$1"
  local plugin_name=${${1##*/}%.git}
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}/$plugin_name"

  # clone if the plugin isn't there already
  if [[ ! -d $plugindir ]]; then
    command git clone --depth 1 --recursive --shallow-submodules $giturl $plugindir
    [[ $? -eq 0 ]] || { >&2 echo "plugin-load: git clone failed; $1" && return 1 }
  fi

  # symlink an init.zsh if there isn't one so the plugin is easy to source
  if [[ ! -f $plugindir/init.zsh ]]; then
    local initfiles=(
      # look for specific files first
      $plugindir/$plugin_name.plugin.zsh(N)
      $plugindir/$plugin_name.zsh(N)
      $plugindir/$plugin_name(N)
      $plugindir/$plugin_name.zsh-theme(N)
      # then do more aggressive globbing
      $plugindir/*.plugin.zsh(N)
      $plugindir/*.zsh(N)
      $plugindir/*.zsh-theme(N)
      $plugindir/*.sh(N)
    )
    [[ ${#initfiles[@]} -gt 0 ]] || { >&2 echo "plugin-load: no plugin init file found" && return 1 }
    command ln -s ${initfiles[1]} $plugindir/init.zsh
  fi

  # source the plugin
  source $plugindir/init.zsh

  # modify fpath
  fpath+=$plugindir
  [[ -d $plugindir/functions ]] && fpath+=$plugindir/functions
}
```

That's it. ~40 lines of code and you have eveything you need to get Zsh plugins.

What this does is simply clones a Zsh plugin's git repository, and then examines that
repo for an appropriate .zsh file to use as an init script. We then symlink an
"init.zsh", which allows us to get the performance advantage of static sourcing rather
than searching for which plugin files to load every time we open a new terminal.

Then, the init.zsh is sourced and the plugin is added to the `fpath`.

### :question: How do I actually load (source) my plugins?

Add a snippet like the following to your `.zshrc`:

```zsh
# where should we store your Zsh plugins?
ZPLUGINDIR=$HOME/.zsh/plugins

# add your plugins to this list
plugins=(
  # core plugins
  mafredri/zsh-async
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search

  # user plugins
  rupa/z
  peterhurford/up.zsh
  rummik/zsh-tailf

  # prompts
  sindresorhus/pure

  # load this one last
  zsh-users/zsh-syntax-highlighting
)

# clone, source, and add to fpath
for repo in $plugins; do
  plugin-load https://github.com/${repo}.git
done
unset repo
```

### :question: How do I update my plugins?

Updating your plugins is as simple as deleting the $ZPLUGINDIR and reloading Zsh.

```zsh
ZPLUGINDIR=$HOME/.zsh/plugins
rm -rfi $ZPLUGINDIR
zsh
```

If you are comfortable with `git` commands and prefer to not rebuild everything, you
can run `git pull` yourself, or even use a simple `plugin-update` function:

```zsh
function plugin-update () {
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}"
  for d in $plugindir/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}
```

### :question: How do I list my plugins?

You can see what plugins you have installed with a simple `ls` command:

```zsh
ls $ZPLUGINDIR
```

If you need something fancier and would like to see the git origin of your plugins, you
could run this command:

```zsh
for d in $ZPLUGINDIR/*/.git; do
  git -C "${d:h}" remote get-url origin
done
```

### :question: How do I remove a plugin?

You can just remove it from your `plugins` list in your .zshrc. To delete it
alltogether, feel free to run `rm`:

```zsh
# remove the fast-syntax-highlighting plugin
rm -rfi $ZPLUGINDIR/fast-syntax-highlighting
```

### :question: What if I want my plugins to be even faster?

If you are an experienced Zsh user, you may know about [zcompile], which takes your
Zsh scripts and potentially speeds them up by compiling them to byte code. If you feel
confident you know what you're doing and want to eek every last bit of performance out
of your Zsh, you can use this function

```zsh
function plugin-compile () {
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}"
  autoload -U zrecompile
  local f
  for f in $plugindir/**/*.zsh{,-theme}; do
    zrecompile -pq "$f"
  done
}
```

[zinit-docs-reddit]: https://www.reddit.com/r/zsh/comments/mur6eu/anyone_interested_in_zinit_documentation/
[awesome-zsh-plugins]: https://github.com/unixorn/awesome-zsh-plugins
[zdharma-debacle]: https://www.reddit.com/r/zsh/comments/qinb6j/httpsgithubcomzdharma_has_suddenly_disappeared_i/
[zcompile]: https://github.com/antonio/zsh-config/blob/master/help/zcompile
[antibody]: https://github.com/getantibody/antibody
[antigen]: https://github.com/zsh-users/antigen
[mzpm]: https://github.com/xylous/mzpm
[pz]: https://github.com/mattmc3/pz
[sheldon]: https://github.com/rossmacarthur/sheldon
[tzpm]: https://github.com/notusknot/tzpm
[uz]: https://github.com/maxrodrigo/uz
[zcomet]: https://github.com/agkozak/zcomet
[zed]: https://github.com/MunifTanjim/zed
[zgem]: https://github.com/qoomon/zgem
[zgen]: https://github.com/tarjoilija/zgen
[zgenom]: https://github.com/jandamm/zgenom
[zinit-continuum]: https://github.com/zdharma-continuum/zinit
[zinit]: https://github.com/zdharma/zinit
[zit]: https://github.com/thiagokokada/zit
[znap]: https://github.com/marlonrichert/zsh-snap
[zplug]: https://github.com/zplug/zplug
[zpm]: https://github.com/zpm-zsh/zpm
[zr]: https://github.com/jedahan/zr

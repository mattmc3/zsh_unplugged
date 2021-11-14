# zsh_unplugged

🤔 perhaps you don't need a Zsh plugin manager after all...

TLDR? Click here to [skip to the code](#gemini-the-humble-plugin-load-function).

## :electric_plug: Zsh Plugin Managers

### :newspaper_roll: Current state

There are an embarassingly large number of Zsh plugin managers out there. Many of them
are abandonware, are no longer actively developed, are brand new without many users, or
don't have much reason to even exist other than as a novelty.

Here's a list of many (but certainly not all) of them from [awesome-zsh-plugins]:

| Zsh Plugin Manager | Performance        | Current state                                   |
|--------------------|--------------------|-------------------------------------------------|
| [antibody]         | :rabbit2: fast     | :imp: Maintenance mode, no new features         |
| [antigen]          | :turtle: slow      | :imp: Maintenance mode, no new features         |
| [pz]               | :rabbit2: fast     | :white_check_mark: Active                       |
| [sheldon]          | :question: unknown | :white_check_mark: Active                       |
| [zcomet]           | :rabbit2: fast     | :white_check_mark: Active                       |
| [zgem]             | :question: unknown | :skull_and_crossbones: Abandonware              |
| [zgen]             | :rabbit2: fast     | :skull_and_crossbones: Abandonware              |
| [zgenom]           | :rabbit2: fast     | :white_check_mark: Active                       |
| [zinit-continuum]  | :rabbit2: fast     | :white_check_mark: Active [\*][#1]              |
| [zinit]            | :rabbit2: fast     | :cursing_face: Author deleted project           |
| [zit]              | :question: unknown | :imp: Few/no recent commits                     |
| [znap]             | :rabbit2: fast     | :white_check_mark: Active                       |
| [zplug]            | :turtle: slow      | :skull_and_crossbones: Abandonware              |
| [zplugin][zinit]   | :rabbit2: fast     | :cursing_face: Renamed to zinit, author deleted |
| [zpm]              | :rabbit2: fast     | :white_check_mark: Active                       |
| [zr]               | :question: unknown | :imp: No recent commits                         |

_Full disclosure, I'm the author of one of these - [pz]._

There's new ones popping up all the time too:

| Zsh Plugin Manager | Performance        | Current state        |
|--------------------|--------------------|----------------------|
| [mzpm]             | :question: unknown | :hatching_chick: New |
| [tzpm]             | :question: unknown | :hatching_chick: New |
| [uz]               | :question: unknown | :hatching_chick: New |
| [zed]              | :question: unknown | :hatching_chick: New |

### :firecracker: The catalyst

I January 2021, the plugin manager I was using, [antibody], was deprecated.
The author even [went so far as to say](https://github.com/getantibody/antibody/tree/2ca7616ae78754c0ab70790229f5d19be42206e9):

> Most of the other plugin managers catch up on performance, thus keeping this \[antibody] does not make sense anymore.

Prior to that, I used [zgen], which also stopped being actively developed and the
[developer](https://github.com/tarjoilija) seems to have disappeared.

In November 2021, a relatively well known and popular Zsh plugin manager, zinit, was
removed from GitHub entirely and without warning. In fact, the author
[deleted almost his entire body of work][zdharma-debacle].

Zinit was really popular because it was super fast, and the author promoted his projects
in multiple venues for many years.

(_Quick shoutout to the folks running [zdharma-continuum] though - great work keeping
Zinit alive!_)

With the instablility in the Zsh plugin manager space, it got me wondering why I even
use a plugin manager at all.

### :bulb: The simple idea

After [antibody] was deprecated, I tried [znap], but it was in active development and
kept breaking, so like many others before me, I decided to write my own - [pz].

When developing [pz], my goal was simple - make a plugin manager in a single Zsh file
that was fast, functional, and easy to understand - which was everything I loved about
[zgen]. While [pz] is still a great project, I kept wondering if I could cut further
from a single file to a single function and do away with plugin management utilities
alltogether.

Thus was born... **zsh_unplugged**.

This isn't a plugin manager - it's a way to show you how to manage your own plugins
without one using small, easy to understand snippets of Zsh. All this with the hope that
perhaps, once-and-for-all, we can do away with the idea that we even need to use a Zsh
plugin manager.

You can simply grab a ~40 line function and you have everything you need to manage your
own plugins from here on out.

## :tada: The code

### :gear: The bare metal way

If you don't want to use anything resemblineg a plugin manager at all, you can simply
clone and source plugins yourself manually:

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

This can get pretty cumbersome and tricky to maintain. You need to figure out each
plugin's init file, and sometimes adding a plugin and its functions dir to your `fpath`
is required. While this method works, there's another way...

### :gemini: The humble `plugin-load` function

If we go one level of abstraction higher than manual `git clone` calls, we can use a
simple function wrapper as the basis for everything you need to manage your own Zsh
plugins:

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

That's it. ~40 lines of code and you have a simple, robust Zsh plugin management
alternative.

What this does is simply clones a Zsh plugin's git repository, and then examines that
repo for an appropriate .zsh file to use as an init script. We then symlink an
"init.zsh", which allows us to get the performance advantage of static sourcing rather
than searching for which plugin files to load every time we open a new terminal.

Then, the init.zsh is sourced and the plugin is added to the `fpath`.

### :question: How do I actually load (source) my plugins?

After grabbing the `plugin-load` function, add a snippet like the following to your
`.zshrc`:

```zsh
# ...the plugin-load function goes here, or sourced from a separate file
# function plugin-load () { ... }

# set where we should store Zsh plugins
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

# load your plugins (clone, source, and add to fpath)
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
altogether, feel free to run `rm`:

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
  for f in $plugindir/**/*.zsh{,-theme}(N); do
    zrecompile -pq "$f"
  done
}
```

### :question: How can I use this with Zsh frameworks like Oh-My-Zsh or Prezto?

[Oh-My-Zsh][ohmyzsh] and [Prezto][prezto] have their own built-in methods for managing
the loading of plugins. You don't need this script if you are using those frameworks.
However, you also don't need a separate plugin manager utility. Here's how you go
plugin manager free with Zsh frameworks:

#### Oh-My-Zsh

If you are using [Oh-My-Zsh][ohmyzsh], the way to go without a plugin manager would be to utilize
the `$ZSH_CUSTOM` path.


_Note that this assumes your init file is called {plugin_name}.plugin.zsh which may not be true._

```zsh
external_plugins=(
  zsh-users/zsh-autosuggestions
  marlonrichert/zsh-hist
  zsh-users/zsh-syntax-highlighting
)
for repo in $external_plugins; do
  if [[ ! -d $ZSH_CUSTOM/${repo:t} ]]; then
    git clone https://github.com/${repo} $ZSH_CUSTOM/plugins/${repo:t}
  fi
done

# add your external plugins to your OMZ plugins list
plugins=(
   ...
   zsh-hist
   zsh-autosuggestions
   ...
   zsh-syntax-highlighting
)
```

#### Prezto

If you are using [Prezto][prezto], the way to go without a plugin manager would be to utilize
the `$ZPREZTODIR/contrib` path.

_Note that this assumes your init file is called {plugin_name}.plugin.zsh which may not be true._

```zsh
external_plugins=(
  rupa/z
  marlonrichert/zsh-hist
  zsh-users/zsh-syntax-highlighting
)
for repo in $external_plugins; do
  if [[ ! -d $ZPREZTODIR/contrib/${repo:t} ]]; then
    git clone https://github.com/${repo} $ZPREZTODIR/contrib/${repo:t}/external
    echo "source \${0:A:h}/external/${repo:t}.plugin.zsh" > $ZPREZTODIR/contrib/${repo:t}/init.zsh
  fi
done

# add plugins to your Prezto plugins list in .zpreztorc
zstyle ':prezto:load' pmodule \
   ... \
   z \
   zsh-hist \
   ... \
   zsh-syntax-highlighting \
```

[zinit-docs-reddit]: https://www.reddit.com/r/zsh/comments/mur6eu/anyone_interested_in_zinit_documentation/
[awesome-zsh-plugins]: https://github.com/unixorn/awesome-zsh-plugins
[zdharma-debacle]: https://www.reddit.com/r/zsh/comments/qinb6j/httpsgithubcomzdharma_has_suddenly_disappeared_i/
[zdharma-continuum]: https://github.com/zdharma-continuum
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
[#1]: https://github.com/mattmc3/zsh_unplugged/issues/1
[ohmyzsh]: https://github.com/ohmyzsh/ohmyzsh
[prezto]: https://github.com/sorin-ionescu/prezto

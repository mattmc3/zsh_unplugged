# zsh_unplugged

🤔 perhaps you don't need a Zsh plugin manager after all...

## :electric_plug: Zsh Plugin Managers

### :newspaper_roll: Current state

There are an embarassingly large number of Zsh plugin managers out there. Many of them
are abandonware, are no longer actively developed, are brand new without many users, or
don't have much reason to even exist other than as a novelty.

Here's a list of many (but probably not all) of them from [awesome-zsh-plugins]:

| Zsh Plugin Manager | Performance        | Current state                                   |
|--------------------|--------------------|-------------------------------------------------|
| [antibody]         | :rabbit2: fast     | :imp: Maintenance mode, no new features         |
| [antigen]          | :turtle: slow      | :skull_and_crossbones: No commits in years      |
| [mzpm]             | :question: unknown | :hatching_chick: New                            |
| [pz]               | :rabbit2: fast     | :white_check_mark: Active                       |
| [sheldon]          | :question: unknown | :white_check_mark: Active                       |
| [tzpm]             | :question: unknown | :hatching_chick: New                            |
| [uz]               | :question: unknown | :hatching_chick: New                            |
| [zcomet]           | :rabbit2: fast     | :white_check_mark: Active                       |
| [zgem]             | :question: unknown | :skull_and_crossbones: Abandonware              |
| [zgen]             | :rabbit2: fast     | :skull_and_crossbones: Abandonware              |
| [zgenom]           | :rabbit2: fast     | :white_check_mark: Active                       |
| [zinit-continuum]  | :rabbit2: fast     | :question: Too early to know                    |
| [zinit]            | :rabbit2: fast     | :cursing_face: Author deleted project           |
| [zit]              | :question: unknown | :imp: No recent commits                         |
| [znap]             | :raccoon: average  | :white_check_mark: Active                       |
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

This isn't a plugin manager - it's a way to once and for all convince you that you
probably don't need a plugin manager to begin with.

## :tada: The code

### :gemini: plugin-clone

This simple function is the basis for everything you need to use Zsh plugins without
the need for an official "Zsh plugin manager":

```zsh
# what if you don't really need a "Zsh plugin manager" after all???
function plugin-clone () {
  emulate -L zsh; setopt local_options null_glob extended_glob
  local giturl="$1"
  local plugin_name=${${1##*/}%.git}
  local plugin_subdir="${ZPLUGINDIR:-$HOME/.zsh/plugins}/$plugin_name"

  # clone if the plugin isn't there already
  if [[ ! -d $plugin_subdir ]]; then
    command git clone --depth 1 --recursive --shallow-submodules $giturl $plugin_subdir
    [[ $? -eq 0 ]] || { >&2 echo "plugin-clone: git clone failed; $1" && return 1 }
  fi

  # symlink an init.zsh if there isn't one so the plugin is easy to source
  if [[ ! -f $plugin_subdir/init.zsh ]]; then
    local initfiles=(
      # look for specific files first
      $plugin_subdir/$plugin_name.plugin.zsh(N)
      $plugin_subdir/$plugin_name.zsh(N)
      $plugin_subdir/$plugin_name(N)
      $plugin_subdir/$plugin_name.zsh-theme(N)
      # then do more aggressive globbing
      $plugin_subdir/*.plugin.zsh(N)
      $plugin_subdir/*.zsh(N)
      $plugin_subdir/*.zsh-theme(N)
      $plugin_subdir/*.sh(N)
    )
    [[ ${#initfiles[@]} -gt 0 ]] || { >&2 echo "plugin-clone: no plugin init file found" && return 1 }
    command ln -s ${initfiles[1]} $plugin_subdir/init.zsh
  fi
}
```

What it does is simply clones a Zsh plugin's git repository, and then examines that repo
for an appropriate .zsh file to use as an init script. Once cloned, we then symlink
an init.zsh so that we can then load the plugin with a known file. By using "init.zsh",
we get the performance advantage of static sourcing.

If the plugin is alread cloned and an init.zsh file exists, then this function exits
fast with no major operations, meaning you can call `plugin-clone` without fear of
slowing down your .zshrc.

### :question: How do I actually load my plugins?

To use `plugin-clone`, simply add that function to your `.zshrc` file, or source
`unplugged.zsh` from this repo if you prefer.

Then, to use plugins, add a snippet like the following to your `.zshrc`:

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

# clone and source
for plugin in $plugins
do
    plugin-clone https://github.com/${plugin}.git
    source $ZPLUGINDIR/${plugin:t}/init.zsh
done
unset plugin
```

### :question: How do I update my plugins?

Updating your plugins is as simple as doing a `git pull` on the plugins you've cloned.
If you aren't comfortable with `git` commands, or prefer a function to help you do this,
here's a simple `plugin-update` function you can use.

```shell
function plugin-update () {
  emulate -L zsh; setopt local_options null_glob extended_glob
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}"
  for d in $plugindir/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}
```

### :question: How do I list my plugins?

You can see what plugins you have installed with a simple `ls` command:

```shell
ls $ZPLUGINDIR
```

If you need something fancier and would like to see the git origin of your plugins, you
could run this command:

```shell
for d in $ZPLUGINDIR/*/.git; do
  git -C "${d:h}" remote get-url origin
done
```

### :question: How do I remove a plugin?

You can just remove it from your `plugins` list in your .zshrc. To delete it
alltogether, feel free to run `rm`:

```shell
# remove the fast-syntax-highlighting plugin
rm -rfi $ZPLUGINDIR/fast-syntax-highlighting
```

### :question: What if I want my plugins to be even faster?

If you are an experienced Zsh user, you may know about [zcompile], which takes your
Zsh scripts and potentially speeds them up by compiling them to byte code. If you feel
confident you know what you're doing and want to eek every last bit of performance out
of your Zsh, you can use this function

```shell
function plugin-compile () {
  emulate -L zsh; setopt local_options null_glob extended_glob
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

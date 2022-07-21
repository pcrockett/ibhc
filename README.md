## Idempotent Bash Host Configuration

This is a template repository. Use it to manage and automate machine configuration using plain Bash.

...but... _why?_

Sometimes you just want to configure a single machine like a personal laptop, or a personal VPS running in the cloud.
With emphasis on the word "personal."

You could manually configure your machine of course, however you like to treat your devices more like _cattle_ and less
like pets. You want the freedom to blow everything away, reinstall your operating system, and get things up and running
quickly again.

You've considered using a script to automate the configuration of your devices, however throwing all that automation
into a single script gets pretty messy (though [writing idempotent Bash][idem-bash] helps).

You've also considered using a _configuration management infrastructure-as-code automation devops microservice
container orchestration engine_ (commonly known in the industry as a "CMIaCADOMCOE"), but decided that would be overkill.

All you really want is a "poor man's" [Ansible][ansible], but with:

* less magic
* less learning curve
* less YAML
* [less Python][xkcd]
* for a single machine

That's what this repository is.

_Disclaimer: This is like, my third attempt at scratching my own itch. I might trash this attempt too, but I feel like
I'm getting close to what I want._

### Simple Example

So your laptop should be treated more like cattle. Great. Let's make it _moo_ like a cow. Fork this repo, clone it to
your laptop, and run the `newtarget` command:

```bash
./bin/newtarget cowsay-installed
```

_If you use [direnv][direnv], you can just run `newtarget` without the `./bin/` part._

That will create a script in the [targets directory](targets) called `cowsay-installed.sh`. The new script looks
something like this:

```bash
#!/usr/bin/env bash

dependencies=()

reached_if() {
    # TODO
}

apply() {
    # TODO
}
```

Assuming you're on a Debian-based machine, fill it out like so:

```bash
#!/usr/bin/env bash

dependencies=(
    lib/apt-updated # This target has already been written for you, see `targets/lib/apt-updated.sh`
)

reached_if() {
    command_is_installed cowsay
    # btw, `command_is_installed` is defined in the `lib.d` directory
    # you can add whatever helper functions you want there
}

apply() {
    apt_install cowsay
    # apt_install is also defined in `lib.d`, and is just a shortcut for `sudo apt-get install --yes "${@}"`
}
```

Next, create a "moo" target: `./bin/newtarget moo` -- and fill out the `moo.sh` script like so:

```bash
#!/usr/bin/env bash

dependencies=(
    cowsay-installed
)

# We don't need the `reached_if` function for this target, so we deleted it.

apply() {
    cowsay "Mooooo!"
}
```

Now go to [the default target](targets/default.sh) and add your new `moo` target to the dependencies list.

```bash
dependencies=(
    moo
)
```

Now you're ready to rock-n-roll:

```bash
./run.sh
```

This will output the following:

```plaintext
Target lib/apt-updated...

[Lots of output from apt-get update]

lib/apt-updated [done]
Target cowsay-installed...

[Lots of output from apt-get install]

cowsay-installed [done]
Target moo...
 _________
< Mooooo! >
 ---------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
moo [done]
default [done]
```

Congratulations, you have a cow. Yay. Nothing too special here.

However look at what happens when you run it a second time:

```plaintext
cowsay-installed [already satisfied]
Target moo...
 _________
< Mooooo! >
 ---------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
moo [done]
default [done]
```

Notice we didn't try to install `cowsay` again, and there's no mention of `apt-updated` at all. That's because we wrote
`cowsay-installed` in an _idempotent_ way. The `reached_if` function saw that `cowsay` was already there, so we skipped
that target and went straight to `moo`.

This pattern enables you to build your machine configuration over time, re-running your configuration scripts as many
times as you want, with pretty minimal logic. And if you have a fairly decent grasp of Bash, you should be able to
comprehend and customize how this whole thing works really quickly. It's not much code.

Other features include:

* run specific targets, not just the `default` one (i.e. "software-update", "backup", "restore")
* create different templates for different types of targets
* run targets based on whether a file has been changed
    * see `file_is_unchanged`, `set_file_unchanged`, and `set_file_dirty` functions in the `lib.d` directory

### Recommended Dependencies

The only thing you _need_ for all this to work is Bash. However installing these could help improve your quality of life
a little bit:

* [direnv][direnv]
* [shellcheck][shellcheck]
* `make`

[idem-bash]: https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/
[ansible]: https://www.ansible.com/
[xkcd]: https://xkcd.com/1987/
[direnv]: https://direnv.net/
[shellcheck]: https://github.com/koalaman/shellcheck

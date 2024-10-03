---
layout: post
title: "Switching from virtualenvwrapper to direnv, Starship, and uv"
date: 2024-10-03 13:30:00 -0700
comments: true
categories: python direnv uv starship dotfiles
---

Earlier this week I considered whether I should finally switch away from [virtualenvwrapper][] to using local `.venv` managed by [direnv][].

I've never seriously used direnv, but I've been hearing [Jeff][] and [Hynek][] talk about their use of direnv for a while.

After a few days, I've finally stumbled into a setup that works great for me.
I'd like to note the basics of this setup as well as some fancy additions that are specific to my own use case.


## My old virtualenvwrapper workflow

First, I'd like to note my *old* workflow that I'm trying to roughly recreate:

1. I type `mkvenv3 <project_name>` to create a new virtual environment for the current project directory and activate it
2. I type `workon <project_name>` when I want to workon that project: this activates the correct virtual environment *and* changes to the project directory

The initial setup I thought of allows me to:

1. Run `echo layout python > .envrc && direnv allow` to create a virtual environment for the current project and activate it
2. Change directories into the project directory to automatically activate the virtual environment

The more complex setup I eventually settled on allows me to:

1. Run `venv <project_name>` to create a virtual environment for the current project and activate it
1. Run `workon <project_name>` to change directories into the project (which automatically activates the virtual environment)


## The initial setup

First, I [installed direnv][direnv] and added this to my `~/.zshrc` file:

```bash
eval "$(direnv hook zsh)"
```

Then whenever I wanted to create a virtual environment for a new project I created a `.envrc` file in that directory, which looked like this:

```bash
layout python
```

Then I ran `direnv allow` to allow, as `direnv` instructed me to, to allow the new virtual environment to be automatically created and activated.

That's pretty much it.

Unfortunately, I did not like this initial setup.


## No shell prompt?

The first problem was that the virtual environment's prompt didn't show up in my shell prompt.
This is due to a [direnv not allowing modification of the `PS1` shell prompt][PS1].
That means I'd need to modify my shell configuration to show the correct virtual environment name myself.

So I added this to my `~/.zshrc` file to show the virtual environment name at the beginning of my prompt:

```bash
# Add direnv-activated venv to prompt
show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV_PROMPT" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV_PROMPT)) "
  fi
}
PS1='$(show_virtual_env)'$PS1
```


## Wrong virtual environment directory

The next problem was that the virtual environment was placed in `.direnv/python3.12`.
I wanted each virtual environment to be in a `.venv` directory instead.

To do that, I made a `.config/direnv/direnvrc` file that customized the python layout:

```bash
layout_python() {
    if [[ -d ".venv" ]]; then
        VIRTUAL_ENV="$(pwd)/.venv"
    fi

    if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
        log_status "No virtual environment exists. Executing \`python -m venv .venv\`."
        python -m venv .venv
        VIRTUAL_ENV="$(pwd)/.venv"
    fi

    # Activate the virtual environment
    . $VIRTUAL_ENV/bin/activate
}
```


## Loading, unloading, loading, unloading...

I also didn't like the loading and unloading messages that showed up each time I changed directories.
I removed those by clearing the `DIRENV_LOG_FORMAT` variable in my `~/.zshrc` configuration:

```bash
export DIRENV_LOG_FORMAT=
```


## The more advanced setup

I don't like it when all my virtual environment prompts show up as `.venv`.
I want ever prompt to be the name of the actual project... which is usually the directory name.

I also *really* wanted to be able to type `venv` to create a new virtual environment, activate it, and create the `.envrc` file for my *automatically*.

Additionally, I thought it would be really handy if I could type `workon <project_name>` to change directories to a specific project.

I made two aliases in my `~/.zshrc` configuration for all of this:

```shell
venv() {
    local venv_name=${1:-$(basename "$PWD")}
    local projects_file="$HOME/.projects"

    # Check if .envrc already exists
    if [ -f .envrc ]; then
        echo "Error: .envrc already exists" >&2
        return 1
    fi

    # Create venv
    if ! python3 -m venv --prompt "$venv_name"; then
        echo "Error: Failed to create venv" >&2
        return 1
    fi

    # Create .envrc
    echo "layout python" > .envrc

    # Append project name and directory to projects file
    echo "${venv_name} = ${PWD}" >> $projects_file

    # Allow direnv to immediately activate the virtual environment
    direnv allow
}

workon() {
    local project_name="$1"
    local projects_file="$HOME/.projects"
    local project_dir

    # Check for projects config file
    if [[ ! -f "$projects_file" ]]; then
        echo "Error: $projects_file not found" >&2
        return 1
    fi

    # Get the project directory for the given project name
    project_dir=$(grep -E "^$project_name\s*=" "$projects_file" | sed 's/^[^=]*=\s*//')

    # Ensure a project directory was found
    if [[ -z "$project_dir" ]]; then
        echo "Error: Project '$project_name' not found in $projects_file" >&2
        return 1
    fi

    # Ensure the project directory exists
    if [[ ! -d "$project_dir" ]]; then
        echo "Error: Directory $project_dir does not exist" >&2
        return 1
    fi

    # Change directories
    cd "$project_dir"
}
```

Now I can type this to create a `.venv` virtual environment in my current directory, which has a prompt named after the current directory, activate it, and create a `.envrc` file which will automatically activate that virtual environment (thanks to that `~/.config/direnv/direnvrc` file) whenever I change into that directory:

```bash
$ venv
```

If I wanted to customized the prompt name for the virtual environment, I could do this:

```bash
$ venv my_project
```

When I wanted to start working on that project later, I can either change into that directory *or* if I'm feeling lazy I can simply type:

```bash
$ workon my_project
```

That reads from my `~/.projects` file to look up the project directory to switch to.


## Switching to uv

I also decided to try using [uv][] for all of this, since it's faster at creating virtual environments.
One benefit of `uv` is that it tries to select the correct Python version for the project, if it sees a version noted in a `pyproject.toml` file.

Another benefit of using `uv`, is that I should also be able to update the `venv` to use a specific version of Python with something like `--python 3.12`.

Here are the updated shell aliases for the `~/.zshrc` for `uv`:

```shell
venv() {
    local venv_name
    local dir_name=$(basename "$PWD")

    # If there are no arguments or the last argument starts with a dash, use dir_name
    if [ $# -eq 0 ] || [[ "${!#}" == -* ]]; then
        venv_name="$dir_name"
    else
        venv_name="${!#}"
        set -- "${@:1:$#-1}"
    fi

    # Check if .envrc already exists
    if [ -f .envrc ]; then
        echo "Error: .envrc already exists" >&2
        return 1
    fi

    # Create venv using uv with all passed arguments
    if ! uv venv --seed --prompt "$@" "$venv_name"; then
        echo "Error: Failed to create venv" >&2
        return 1
    fi

    # Create .envrc
    echo "layout python" > .envrc

    # Append to ~/.projects
    echo "${venv_name} = ${PWD}" >> ~/.projects

    # Allow direnv to immediately activate the virtual environment
    direnv allow
}
```


## Switching to starship

I also decided to try out using [Starship][] to customize my shell this week.

I added this to my `~/.zshrc`:

```bash
eval "$(starship init zsh)"
```

And removed this, which is no longer needed since Starship will be managing the shell for me:

```bash
# Add direnv-activated venv to prompt
show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV_PROMPT" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV_PROMPT)) "
  fi
}
PS1='$(show_virtual_env)'$PS1
```

```
layout_python() {
    VIRTUAL_ENV="$(pwd)/.venv"

    # These lines work for activating the virtual environment for starship
    PATH_add "$VIRTUAL_ENV/bin"
    export VIRTUAL_ENV

    # This would be necessary or a non-starship shell, to update the prompt
    # . $VIRTUAL_ENV/bin/activate
}
```

I also made a *very* boring Starship configuration in `~/.config/starship.toml`:

```toml
format = """
$python\
$directory\
$git_branch\
$git_state\
$character"""

add_newline = false

[python]
format = '([(\($virtualenv\) )]($style))'
style = "bright-black"

[directory]
style = "bright-blue"

[character]
success_symbol = "[\\$](black)"
error_symbol = "[\\$](bright-red)"
vimcmd_symbol = "[❮](green)"

[git_branch]
format = "[$symbol$branch]($style) "
style = "bright-purple"

[git_state]
format = '\([$state( $progress_current/$progress_total)]($style)\) '
style = "purple"

[cmd_duration.disabled]
```

I setup such a boring configuration because when I'm teaching, I don't want my students to be confused or distracted by a prompt that has considerably more information in it than *their* default prompt may have.

The biggest downside of switching to Starship has been my own earworm-oriented brain.
As I update my Starship configuration files, I've repeatedly heard David Bowie singing "I'm a Starmaaan". 🎶


## Ground control to major TOML

After all of that, I realized that I could additionally use different Starship configurations for different directories by putting a `STARSHIP_CONFIG` variable in specific layouts.
After that realization, I made my configuration even *more* vanilla and made some alternative configurations in my `~/.config/direnv/direnvrc` file:

```bash
layout_python() {
    VIRTUAL_ENV="$(pwd)/.venv"

    PATH_add "$VIRTUAL_ENV/bin"
    export VIRTUAL_ENV

    export STARSHIP_CONFIG=/home/trey/.config/starship/python.toml
}

layout_git() {
    export STARSHIP_CONFIG=/home/trey/.config/starship/git.toml
}
```

Those other two configuration files are fancier, as I have no concern about them distracting my students since I'll never be within those directories while teaching.

You can find those files in [my dotfiles repository][dotfiles].


## The necessary tools

So I replaced virtualenvwrapper with direnv, uv, and Starship.
Though direnv was is doing most of the important work here.
The use of uv and Starship were just bonuses.

I *am* also hoping to eventually replace my pipx use with uv and once uv supports [adding python3.x commands][python shims] to my `PATH`, I may replace my use of pyenv with uv as well.


[virtualenvwrapper]: https://virtualenvwrapper.readthedocs.io
[jeff]: https://micro.webology.dev/2024/03/13/on-environment-variables.html
[hynek]: https://hynek.me/til/python-project-local-venvs/
[direnv]: https://direnv.net
[ps1]: https://github.com/direnv/direnv/issues/529
[uv]: https://docs.astral.sh/uv/
[starship]: https://starship.rs
[dotfiles]: https://github.com/treyhunner/dotfiles
[python shims]: https://github.com/astral-sh/uv/issues/6265

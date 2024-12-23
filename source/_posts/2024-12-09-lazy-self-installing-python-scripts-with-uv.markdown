---
layout: post
title: "Lazy self-installing Python scripts with uv"
date: 2024-12-09 11:15:10 -0800
comments: true
categories: python uv
---

I frequently find myself writing my own short command-line scripts in Python that help me with day-to-day tasks.

It's *so* easy to throw together a single-file Python command-line script and throw it in my `~/bin` directory!

Well... it's easy, *unless* the script requires anything outside of the Python standard library.

Recently I've started using uv and my *primary* for use for it has been fixing Python's "just manage the dependencies automatically" problem.

I'll share how I've been using uv... first first let's look at the problem.


## A script without dependencies

If I have a Python script that I want to be easily usable from anywhere on my system, I typically follow these steps:

1. Add an appropriate shebang line above the first line in the file (e.g. `#!/usr/bin/env python3`)
2. Set an executable bit on the file (`chmod a+x my_script.py`)
3. Place the script in a directory that's in my shell's `PATH` variable (e.g. `cp my_script.py ~/bin/my_script`)

For example, here's a script I use to print out 80 zeroes (or a specific number of zeroes) to check whether my terminal's font size is large enough when I'm teaching:

```python
#!/usr/bin/env python3
import sys

numbers = sys.argv[1:] or [80]
for n in numbers:
    print("0" * int(n))
```

This file lives at `/home/trey/bin/0` so I can run the command `0` from my system prompt to see 80 `0` characters printed in my terminal.

This works great!
But this script doesn't have any dependencies.


## The problem: a script with dependencies

Here's a Python script that normalizes the audio of a given video file and writes a new audio-normalized version of the video to a new file:

```python
"""Normalize audio in input video file."""
from argparse import ArgumentParser
from pathlib import Path

from ffmpeg_normalize import FFmpegNormalize


def normalize_audio_for(video_path, audio_normalized_path):
    """Return audio-normalized video file saved in the given directory."""
    ffmpeg_normalize = FFmpegNormalize(audio_codec="aac", audio_bitrate="192k", target_level=-17)
    ffmpeg_normalize.add_media_file(str(video_path), audio_normalized_path)
    ffmpeg_normalize.run_normalization()


def main():
    parser = ArgumentParser()
    parser.add_argument("video_file", type=Path)
    parser.add_argument("output_file", type=Path)
    args = parser.parse_args()
    normalize_audio_for(args.video_file, args.output_file)


if __name__ == "__main__":
    main()
```

This script depends on the [ffmpeg-normalize][] Python package and the [ffmpeg][] utility.
I already have `ffmpeg` installed, but I prefer *not* to globally install Python packages.
I install all Python packages within virtual environments and I install global Python scripts using [pipx][].

At this point I *could* choose to either:

1. Create a virtual environment, install `ffmpeg-normalize` in it, and put a shebang line referencing that virtual environment's Python binary at the top of my script file
2. Turn my script into a `pip`-installable Python package with a `pyproject.toml` that lists `ffmpeg-normalize` as a dependency and use `pipx` to install it

That first solution requires me to keep track of virtual environments that exist for specific scripts to work.
That sounds painful.

The second solution involves making a Python package and then upgrading that Python package whenever I need to make a change to this script.
That's definitely going to be painful.


## The solution: let uv handle it

A few months ago, my friend [Jeff Triplett](https://micro.webology.dev) showed me that `uv` can work within a shebang line and can read a special comment at the top of a Python file that tells uv which Python version to run a script with and which dependencies it needs.

Here's a shebang line that would work for the above script:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "ffmpeg-normalize",
# ]
# ///
```

That tells uv that this script should be run on Python 3.12 and that it depends on the `ffmpeg-normalize` package.

Neat... but what does that do?

Well, the first time this script is run, uv will create a virtual environment for it, install `ffmpeg-normalize` into that venv, and then run the script:

```bash
$ normalize
Reading inline script metadata from `/home/trey/bin/normalize`
Installed 4 packages in 5ms
usage: normalize [-h] video_file output_file
normalize: error: the following arguments are required: video_file, output_file
```

Every time the script is run after that, uv finds and reuses the same virtual environment:

```bash
$ normalize
Reading inline script metadata from `/home/trey/bin/normalize`
usage: normalize [-h] video_file output_file
normalize: error: the following arguments are required: video_file, output_file
```

Each time uv runs the script, it quickly checks that all listed dependencies are properly installed with their correct versions.

Another script I use this for is [caption](https://github.com/treyhunner/dotfiles/blob/main/bin/caption), which uses whisper (via the Open AI API) to quickly caption my screencasts just after I record and edit them.
The caption quality very rarely need more than a very minor edit or two (for my personal accent of English at least) even for technical like "dunder method" and via the API the captions generate very quickly.

See the [inline script metadata](https://packaging.python.org/en/latest/specifications/inline-script-metadata/) page of the Python packaging users guide for more details on that format that uv is using (honestly I always just copy-paste an example myself).


## uv everywhere?

I haven't yet fully embraced uv everywhere.

I don't manage my Python projects with uv, though I do use it to create new virtual environments (with `--seed` to ensure the `pip` command is available) as a [virtualenvwrapper replacement, along with direnv](https://treyhunner.com/2024/10/switching-from-virtualenvwrapper-to-direnv-starship-and-uv/).

I have also started using [uv tool][] as a [pipx][] replacement and I've considered replacing [pyenv][] with uv.


## uv instead of pipx

When I want to install a command-line tool that happens to be Python powered, I used to do this:

```bash
$ pipx countdown-cli
```

Now I do this instead:

```bash
$ uv tool install countdown-cli
```

Either way, I end up with a `countdown` script in my `PATH` that automatically uses its own separate virtual environment for its dependencies:

```bash
$ countdown --help
Usage: countdown [OPTIONS] DURATION

  Countdown from the given duration to 0.

  DURATION should be a number followed by m or s for minutes or seconds.

  Examples of DURATION:

  - 5m (5 minutes)
  - 45s (45 seconds)
  - 2m30s (2 minutes and 30 seconds)

Options:
  --version  Show the version and exit.
  --help     Show this message and exit.
```


## uv instead of pyenv

For years, I've used pyenv to manage multiple versions of Python on my machine.

```bash
$ pyenv install 3.13.0
```

Now I could do this:

```bash
$ uv python install --preview 3.13.0
```

Or I could make a `~/.config/uv/uv.toml` file containing this:

```
preview = true
```

And then run the same thing without the `--preview` flag:

```bash
$ uv python install 3.13.0
```

This puts a `python3.10` binary in my `~/.local/bin directory`, which is on my `PATH`.

Why "preview"?
Well, without it uv doesn't ([yet](https://github.com/astral-sh/uv/issues/6265#issuecomment-2461107903)) place `python3.13` in my `PATH` by default, as this feature is currently in testing/development.


## Self-installing Python scripts are the big win

I still prefer pyenv for its ability to [install custom Python builds](https://treyhunner.com/2024/05/installing-a-custom-python-build-with-pyenv/) and I don't have a preference between `uv tool` and `pipx`.

The biggest win that I've experienced from uv so far is the ability to run an executable script and have any necessary dependencies install automagically.

This doesn't mean that I *never* make Python package out of my Python scripts anymore... but I do so much more rarely.
I used to create a Python package out of a script as soon as it required third-party dependencies.
Now my "do I *really* need to turn this into a proper package" bar is set much higher.


[uv tool]: https://docs.astral.sh/uv/concepts/tools/
[pipx]: https://pipx.pypa.io
[pyenv]: https://pipx.pypa.io/stable/
[ffmpeg]: https://ffmpeg.org
[ffmpeg-normalize]: https://github.com/slhck/ffmpeg-normalize

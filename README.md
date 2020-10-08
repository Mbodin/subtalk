
# Description

A program to generate well-spaced subtitles from a script.

# Installation

To compile the program, you will need to install `esy`.
One way to install `esy` is through npm:
```bash
npm install --global esy
```

Once installed, compile the project with `esy`:
```bash
esy
```

The compiled program is then available in `_build/default/src/main.exe`.
To get more help, type:
```bash
_build/default/src/main.exe -h
```

For instance, given a text file `example.txt`, to convert it into `example.srt` lasting 10 minutes, do the following:
```bash
_build/default/src/main.exe -i example.txt -o example.srt -l 10m
```
The file `example.srt` will then contain all the sentences of `example.txt`, but spaced out such that the total duration of `example.srt` will be 10 minutes.

To add pauses in the text `example.txt`, use the `*` character.
These will be interpreted as a constant pause (by default of half a second).
It particular, it won’t be stretched out like syllables to fit the target time.

A common usage is to create subtitle files meant to read outloud, for instance for a karaoke.
In such a usage, it may be useful to display more than one line simultaneously.
Use the `-g N` option to group `N` line together.
For instance, the following invocation will create a file `example.srt` with groups of three lines, thus always displaying the next two sentences.
```bash
_build/default/src/main.exe -i example.txt -o example.srt -l 10m -g 3
```

# Licence

Copyright © 2020 Martin Constantino–Bodin

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

The program is under the GNU General Public License 3 (GPLv3).
See the file [LICENSE](./LICENSE) for more information.


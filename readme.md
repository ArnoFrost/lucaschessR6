Lucas Chess (R6)
================

Lucas Chess (R6) is a GUI of chess:

1. To train in many different ways.
2. To play chess against any UCI engine.
3. To compete against engines to obtain an elo.
4. It has utilities to edit games, create polyglot books, tournaments between engines ...

This is an update of Lucas Chess with a new version of python (3.7 -> 3.12) and the main graphic library, from pyside2 to pyside6 (qt5 -> qt6).


Incompatibilities
-----------------
* **Does not support Windows 8 or previous versions.**
* **Not compatible with 32-bit operating systems.**

Dependencies
------------

* Python 3.12+
* charset-normalizer
* sortedcontainers
* python-chess
* pillow
* psutil
* polib
* deep-translator
* requests
* urllib3
* idna
* certifi
* beautifulsoup4

macOS (this fork)
-----------------

This fork (`feat/macos-mvp`) adds lightweight macOS support on top of upstream Lucas Chess R6.

**Requirements**

* macOS 11+
* Python 3.12 (Homebrew: `brew install python@3.12`)
* Stockfish for the built-in engine: `brew install stockfish`
* Git LFS (see below)

**Quick start**

```bash
git clone https://github.com/ArnoFrost/lucaschessR6.git
cd lucaschessR6
git checkout feat/macos-mvp
./bin/run_mac.sh
```

First run creates `venv/`, installs dependencies, and builds `FasterCode` if needed.

**Launch options**

| Method | How |
|--------|-----|
| Terminal | `./bin/run_mac.sh` |
| Double-click | `LucasChess.command` (opens Terminal) |
| App bundle | Run `bin/macos/build_app.sh`, then open `LucasChess.app` |

Drag `LucasChess.app` to **Applications** or the **Dock** for a native icon and one-click launch.

**Note:** `LucasChess.app` must stay inside the repository folder (it launches the project via relative path). The first launch from `.app` may rebuild the Python venv with embedded binaries (~1–2 min) — wait for the notification. If `.app` is blocked by macOS, run: `xattr -cr LucasChess.app`

**Keyboard shortcuts on Mac**

Main-window shortcuts use **⌘ (Command)** instead of Ctrl (e.g. ⌘0 shortcuts menu, ⌘1/⌘2 toolbar actions).

Important Note for Developers / Cloning
---------------------------------------

This repository uses **Git LFS (Large File Storage)** to manage large binary files (such as chess engines, networks, or databases).

If you download the repository using the GitHub web interface as a **.zip file, these large files will not be included correctly** (you will only get small text pointer files).

To get a complete and working copy of the project, please ensure you have **Git LFS** installed on your system before cloning.

1. **Install Git LFS** (if you haven't already):
   - Windows: `winget install GitHub.GitLFS` or download from [git-lfs.github.com](https://git-lfs.github.com/)
   - Mac: `brew install git-lfs`
   - Linux: `sudo apt install git-lfs`

2. **Initialize Git LFS** in your terminal:
   ```bash
   git lfs install

3. Clone the repository:
   ```bash
   git clone https://github.com/lukasmonk/lucaschessR6.git

Links
-----

* Web: [https://lucaschess.pythonanywhere.com/](https://lucaschess.pythonanywhere.com/).
* Blog: [https://lucaschess.blogspot.com.es/](https://lucaschess.blogspot.com.es/).


Legal Details
-------------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA

See the file "LICENSE" for details.




vim-analog v0.1.0 :coffee:
==========================

[![Build status](https://travis-ci.org/MisanthropicBit/vim-analog.svg?branch=master)](https://travis-ci.org/MisanthropicBit/vim-analog)

![Example of using vim-analog](https://github.com/MisanthropicBit/vim-analog/demos/demo.gif)

A plugin for getting information about the open hours and staff of the Analog café at the IT
University of Copenhagen from within vim.

[Contributions are always welcome](https://github.com/MisanthropicBit/vim-analog/CONTRIBUTING.md)!

See the list suggested of [future improvements](https://github.com/MisanthropicBit/vim-analog/FUTURE.md).

Installation
------------

You can install `vim-analog` using Pathogen:

```
cd ~/.vim/bundle
git clone https://github.com/MisanthropicBit/vim-task
```

Alternatively, you can use Vundle by adding the following to your .vimrc:

    Plugin 'MisanthropicBit/vim-task'

Or any other plugin manager you might prefer.

Unicode support
---------------

To check if your terminal supports unicode, run the following (`bash` v4+):

```
echo -e '\u2615 \u2714 \u2717'
```

Otherwise, try this:

```
echo -e '\xe2\x98\x95 \xe2\x9c\x94 \xe2\x9c\x97'
```

You should see a coffee cup, a checkmark and an X: "☕ ✔ ✗"

# vim-analog v1.0.0 ![Build status](https://travis-ci.org/MisanthropicBit/vim-analog.svg?branch=master) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/MisanthropicBit/vim-analog/master/LICENSE)

A plugin for querying the open hours and staff of the [Analog
café](http://cafeanalog.dk/) at the IT University of Copenhagen from within vim.

See the list of suggested [future improvements](/FUTURE.md).

![Example of using vim-analog](/demo.gif?raw=true)

## Requirements

`vim-analog` needs either `curl` or `wget` installed and at least `vim` 7.4.1154
for json support.

## Installation

`vim-analog` is `pathogen`-compatible and can be installed with various plugin managers:

* [Pathogen](https://github.com/tpope/vim-pathogen):
  `git clone https://github.com/MisanthropicBit/vim-analog ~/.vim/bundle/vim-analog`
* [NeoBundle](https://github.com/Shougo/neobundle.vim):
  `NeoBundle 'MisanthropicBit/vim-analog'`
* [VAM](https://github.com/MarcWeber/vim-addon-manager):
  `call vam#ActivateAddons(['MisanthropicBit/vim-analog'])`
* [Vundle](https://github.com/VundleVim/Vundle.vim):
  `Plugin 'MisanthropicBit/vim-analog'`

## Unicode support

To check if your terminal supports unicode, run the following (`bash` v4.0+):

```
printf '\u2615 \u2714 \u2717\n'
```

Otherwise, try this:

```
printf '\xe2\x98\x95 \xe2\x9c\x94 \xe2\x9c\x97\n'
```

You should see a coffee cup, a checkmark and an X: "☕ ✔ ✗"

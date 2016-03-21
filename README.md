vim-analog v0.1.0
=================

![Example of using vim-analog](https://github.com/MisanthropicBit/vim-analog/demos/demo.gif)

A small plugin for getting information about the open hours and staff of the Analog café at the IT
University of Copenhagen from within vim.

* OSX notifications before Analog closes
* Automatically updated [`vim-airline`](https://github.com/vim-airline/vim-airline) status bar
* Commands for getting information about Analog

See the list suggested of [future improvements](https://github.com/MisanthropicBit/FUTURE.md).

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

You should see a coffee cup, a checkmark and an X: "☕  ✔ ✗"

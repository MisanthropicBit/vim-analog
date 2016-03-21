Timers in `vim`
===============

`vim` provides no built-in timer support, i.e. calling some function every 100 milliseconds. Nonetheless, `vim-analog` needs
some notion of periodic calls to be able to support updated status bar changes.

The closest thing is the `autocmd` `CursorHold`. If `vim` receives no input for `updatetime` milliseconds the command in the
declaration of the `autocmd` is executed. Many plugins rely on this functionaility and change the global value of `updatetime`.
Therefore, `vim-analog` does **not** change it, but assumes that it has been set to a reasonable value.

For more information, see `:help CursorHold`. For a more lengthy discussion on `CursorHold`, see [this](https://news.floobits.com/2013/09/16/adding-realtime-collaboration-to-vim/).

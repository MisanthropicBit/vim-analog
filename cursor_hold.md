"Timers" in `vim`
=================

`vim` provides no built-in timer support, i.e. periodically calling a function every 100 milliseconds. Nonetheless, `vim-analog` needs
some notion of periodic calls to be able to support updated status bar changes.

The closest thing is the `autocmd` `CursorHold`. If `vim` receives no input for `updatetime` milliseconds the command in the
declaration of the `autocmd` is executed. However, many plugins rely on this functionaility and change the global value of
`updatetime`. Therefore, to remain as conflict-free as possible, `vim-analog` does **not** change its value, but assumes that
it has been set to a reasonable value.

For more information, see `:help CursorHold`. For a more lengthy discussion on `CursorHold`, see [this](https://news.floobits.com/2013/09/16/adding-realtime-collaboration-to-vim/).

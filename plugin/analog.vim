if exists('g:loaded_analog') || &cp || v:version < 700
    finish
endif

" Initialisation function {{{
function! s:VimAnalogInit()
    if g:analog#prefer_symbols && !has("multi_byte")
        let g:analog#prefer_symbols = 0
    endif
endfunction
" }}}

" Configuration variables {{{
" General {{{
let g:analog#version = "0.1.0"

if has('multi_byte')
    " The unicode representation of the coffee cup symbol,
    " may differ based on your font. The codepoint is U+2615
    "
    " Note: Extra space inserted after the coffee cup symbol,
    " since vim represents the symbol width incorrectly
    let g:analog#coffee_symbol = '☕  ✓'
    let g:analog#no_coffee_symbol = '☕  ✗'
    let g:analog#no_connection_symbol = '☕  ?'
else
    let g:analog#coffee_symbol = 'Analog [Open]'
    let g:analog#no_coffee_symbol = 'Analog [Closed]'
    let g:analog#no_connection_symbol = 'Analog [?]'
endif

let g:analog#prefer_symbols = 1
let g:analog#ignore_closed = 1
" }}}

" Commands {{{
command! AnalogVersion echo "vim-analog v" . g:analog#version
command! AnalogOpen call analog#echo_open_status()
command! AnalogHours call analog#echo_open_hours()
command! AnalogStaff call analog#echo_staff()
command! AnalogStaffNow call analog#echo_current_staff()
command! AnalogTimeToClose call analog#echo_time_to_close()
" }}}

" Initialise vim-analog
call s:VimAnalogInit()

let g:loaded_analog = 1

" }}}

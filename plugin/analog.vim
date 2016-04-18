if exists('g:loaded_analog') || &cp || v:version < 700
    finish
endif

" Initialisation function {{{
function! s:VimAnalogInit()
    if g:analog#prefer_symbols && !has("multi_byte")
        let g:analog#prefer_symbols = 0
    endif

    if g:analog#use_osx_notifications && (!has("mac") || has("macunix"))
        let g:analog#use_osx_notifications = 0
    endif

    if g:analog#use_vim_statusline + g:analog#use_vim_airline + g:analog#use_vim_lightline > 1
        echoerr "vim-analog: Cannot simultaneously use the regular statusline, vim-airline or vim-lightline"
        return
    endif

    " Create the vim-airline or vim-lightline status bars
    if g:analog#use_vim_airline
        autocmd User AirlineAfterInit call analog#update_vim_airline(analog#is_open()) | execute "normal! :AirlineRefresh"
    elseif g:analog#use_vim_lightline
        " TODO
        echoerr "vim-analog: vim-lightline is not yet supported"
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
let g:analog#use_vim_statusline = 0
let g:analog#use_vim_airline = 1
let g:analog#vim_airline_section = 'x'
let g:analog#vim_airline_custom_call = ''
let g:analog#use_vim_lightline = 0


if has('mac') || has('macunix')
    let g:analog#use_osx_notifications = 0
    let g:analog#notify_before_close = 300 " 5 minutes
    let g:analog#osx_notification_sound_name = 'Hero'
else
    let g:analog#use_osx_notifications = 0
endif

let g:analog#update_interval = 300
" }}}

" Commands {{{
command! AnalogVersion echo "vim-analog v" . g:analog#version
command! AnalogOpen call analog#echo_open_status()
command! AnalogHours call analog#echo_open_hours()
command! AnalogStaff call analog#echo_staff()
command! AnalogStaffNow call analog#echo_current_staff()
" }}}

" Initialise vim-analog
call s:VimAnalogInit()

let g:loaded_analog = 1

" }}}

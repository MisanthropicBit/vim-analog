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

    if g:analog#use_vim_airline && g:analog#use_vim_lightline
        echoerr "vim-analog: Cannot both use vim-airline and vim-lightline"
        return
    endif

    " Create the vim-airline or vim-lightline status bars
    if g:analog#use_vim_airline
        autocmd User AirlineAfterInit call analog#update_vim_airline()
    elseif g:analog#use_vim_lightline
        " TODO
        echoerr "vim-analog: vim-lightline is not supported yet"
    endif

    "call analog#update()
endfunction
" }}}

" Configuration variables {{{
" General {{{
let g:analog#version = "0.1.0"
let g:analog#prefer_symbols = 1

let g:analog#use_vim_statusline = 0
let g:analog#use_vim_airline = 1
let g:analog#vim_airline_section = 'x'
let g:analog#vim_airline_custom_call = ''
let g:analog#use_vim_lightline = 0

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
    let g:analog#coffee_symbol = 'Analog [OPEN]'
    let g:analog#no_coffee_symbol = 'Analog [CLOSED]'
    let g:analog#no_connection_symbol = 'Analog [?]'
endif

if has('mac') || has('macunix')
    let g:analog#use_osx_notifications = 0
    let g:analog#notify_before_close = 300 " 5 minutes
    let g:analog#osx_notification_sound_name = 'Hero'
else
    let g:analog#use_osx_notifications = 0
endif

let g:analog#update_interval = 300
" }}}

" Web URLs {{{
let g:analog#web#base_url = 'www.cafeanalog.dk/api'
let g:analog#web#open_url = g:analog#web#base_url . '/open'
let g:analog#web#shifts_url = g:analog#web#base_url . '/shifts/today'
" }}}

" Patterns {{{
let g:analog#patterns#json_open = '\v^\{\"open\":(false|true)\}$'
let g:analog#patterns#json_employees = '\v\"Employees\":\[\zs(.{-})\ze\]'
let g:analog#patterns#json_open_hours = '\v\"%(Open|Close)\":\"\zs(.{-})\ze\"'
let g:analog#patterns#json_time = '\v\d{4}-\d{2}-\d{2}T\zs(\d{2}:\d{2})\ze:\d{2}%(\+|-)\d{2}:\d{2}'
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

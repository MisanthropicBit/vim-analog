if exists('g:loaded_analog') || &cp || v:version < 700
    finish
endif

" Configuration variables {{{
" General {{{
let g:analog#version = "1.0.0"

let g:analog#prefer_symbols = get(g:, 'analog#prefer_symbols', 1)

let g:analog#query_command_preference = get(g:, 'analog#query_command_preference', 'curl')
let g:analog#query_command = get(g:, 'analog#query_command', '')

if has('multi_byte') && g:analog#prefer_symbols != 0
    " The unicode representation of the coffee cup symbol,
    " may differ based on your font. The codepoint is U+2615
    "
    " Note: Extra space inserted after the coffee cup symbol,
    " since vim represents the symbol width incorrectly
    let g:analog#coffee_symbol = get(g:, 'analog#coffee_symbol', '☕  ✓')
    let g:analog#no_coffee_symbol = get(g:, 'analog#no_coffee_symbol', '☕  ✗')
    let g:analog#no_connection_symbol = get(g:, 'analog#no_connection_symbol', '☕  ?')
else
    let g:analog#coffee_symbol = get(g:, 'analog#coffee_symbol', 'Analog is open')
    let g:analog#no_coffee_symbol = get(g:, 'analog#no_coffee_symbol', 'Analog is closed')
    let g:analog#no_connection_symbol = get(g:, 'analog#no_connection_symbol', 'No connection')

    if g:analog#prefer_symbols
        let g:analog#prefer_symbols = 0
    endif
endif

let g:analog#notification = get(g:, 'analog#notification', 0)
let g:analog#notify_before_close = get(g:, 'analog#notify_before_close', 300)
let g:analog#notification_sound = get(g:, 'analog#notification_sound', 'Hero')
" }}}

if g:analog#notification && analog#notifications#supported()
    "call timer_start(0, 'analog#notifications#setup')
    call analog#notifications#setup()
endif

" Commands {{{
command! AnalogVersion echo "vim-analog v" . analog#version()
command! AnalogOpen call analog#echo_open_status()
command! AnalogHours call analog#echo_open_hours()
command! AnalogStaff call analog#echo_staff_and_hours()
command! AnalogStaffNow call analog#echo_current_staff()
command! AnalogTimeToClose call analog#echo_time_to_close()
" }}}

let g:loaded_analog = 1

" }}}

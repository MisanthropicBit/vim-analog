" Web URLs {{{
let g:analog#web#base_url = 'www.cafeanalog.dk/api'
let g:analog#web#open_url = g:analog#web#base_url . '/open'
let g:analog#web#shifts_url = g:analog#web#base_url . '/shifts/today'
" }}}

" Patterns {{{
let g:analog#patterns#json_open = '\v^\{\"open\":(false|true)\}$'
let g:analog#patterns#json_employees = '\v\"Employees\":\[\zs(.{-})\ze\]'
let g:analog#patterns#json_open_hours = '\v\"%(Open|Close)\":\"\zs(.{-})\ze\"'
let g:analog#patterns#json_time = '\v\d{4}-\d{2}-\d{2}T\zs\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
let g:analog#patterns#json_full_date = '\v\zs\d{4}-\d{2}-\d{2}T\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
" }}}

" General functions {{{
function! analog#is_open()
    let json = analog#web#request(g:analog#web#open_url, '')

    if len(json) == 0
        return -1
    endif

    let state = matchlist(json, g:analog#patterns#json_open)

    if len(state) > 1
        return (state[1] ==# "true" ? 1 : 0)
    endif

    call analog#print_error_message("vim-analog: Unknown state for open: '%s'", state)
    return -1
endfunction

function! analog#is_open_or_echoerr()
    let state = analog#is_open()

    echohl WarningMsg
    if state == 0
        echo "Analog is closed"
    elseif state == -1
        echo "No connection"
    endif
    echohl NONE

    return state
endfunction

function! analog#get_all_matches(str, pattern)
    let results = []
    call substitute(a:str, a:pattern, '\=add(results, submatch(0))', 'g')

    return results
endfunction

function! analog#get_staff()
    let json = analog#web#request(g:analog#web#shifts_url, '')

    return analog#parse_json_employees(json)
endfunction

function! analog#get_current_staff()
    let json = analog#web#request(g:analog#web#shifts_url, '')
    let staff = analog#parse_json_employees(json)
    let hours = analog#parse_json_open_hours(json)
    let i = analog#time_in_interval(split(strftime('%H:%M'), ':'), hours)

    return staff[i]
endfunction

function! analog#get_open_hours()
    let json = analog#web#request(g:analog#web#shifts_url, '')

    if has("python")
        " TODO!
    endif

    let hours = analog#get_all_matches(json, g:analog#patterns#json_open_hours)
    let intervals = []

    for h in hours
        call add(intervals, matchstr(h, g:analog#patterns#json_time))
    endfor

    return intervals
endfunction

function! analog#print_error_message(format, args)
   echohl WarningMsg
   "echoerr printf(a:format, a:args*)
   echohl NONE
endfunction

" Note: g:airline_section_gutter?
let s:VimAnalogValidAirlineSections = ['a', 'b', 'c', 'x', 'y', 'z', 'warning']

let s:prevState = -2

function! analog#update_vim_airline(state)
    if index(s:VimAnalogValidAirlineSections, g:analog#vim_airline_section) == -1
        return
    endif

    " Do not waste time recreating the airline section if the state did not
    " change since last time
    if s:prevState == a:state
        return
    endif

    let s:prevState = a:state
    let symbol = g:analog#no_connection_symbol
    let color = 'red'

    if a:state != -1
        let symbol = (a:state == 1 ? g:analog#coffee_symbol : g:analog#no_coffee_symbol)
        let color = (a:state == 1 ? 'green' : 'red')
    endif
    
    call analog#construct_airline_section(symbol, color)
endfunction

function! analog#construct_airline_section(symbol, color)
    let airline_part = airline#parts#define('analog', { 'raw': a:symbol, 'accent': a:color })
    let airline_section = 'g:airline_section_' . g:analog#vim_airline_section
    let airline_function = (index(s:VimAnalogValidAirlineSections[:2], g:analog#vim_airline_section) != -1 ? 'left' : 'right')

    execute 'let ' . airline_section . ' = airline#section#create_' . airline_function . '(["analog", ' . airline_section . '])'
endfunction

function! analog#get_current_symbol()
    return [g:analog#no_coffee_symbol, g:analog#coffee_symbol, g:analog#no_connection_symbol][analog#is_open()]
endfunction

function! AnalogDefaultStatusline()
    return '%<%f %h%r%=' . g:analog#coffee_symbol . ' %-14.(%l,%c%V%) %P'
endfunction

function! analog#update()
    let open = analog#is_open()

    if g:analog#use_vim_statusline
        set statusline=%!AnalogDefaultStatusline()
    elseif g:analog#use_vim_airline
        " NOTE: Use 'call AirlineRefresh'?
        call analog#update_vim_airline(open)
    elseif g:analog#use_vim_lightline
        " TODO
        "call analog#update_vim_lightline(open)
    endif

    "let time_to_close = analog#time_to_close()
    "echom string(time_to_close)

    "if min(time_to_close) >= 0
    "    let seconds = time_to_close[0] * 60 * 60 + time_to_close[1] * 60
    "    echom seconds

    "    if seconds <= g:analog#notify_before_close
    "        call analog#notify()
    "    endif
    "endif
endfunction
" }}}

" JSON 'parsing' {{{
function! analog#parse_json_employees(json)
    let results = analog#get_all_matches(a:json, g:analog#patterns#json_employees)

    return map(map(results, 'substitute(v:val, "\"", "", "g")'), 'split(v:val, ",")')
endfunction

function! analog#parse_json_open_hours(json)
    let hours = analog#get_all_matches(a:json, g:analog#patterns#json_open_hours)
    let intervals = []

    for h in hours
        call add(intervals, matchstr(h, g:analog#patterns#json_time))
    endfor

    return intervals
endfunction
" }}}

" Time functions {{{
" TODO: [17, 30] - [18, 26] = [-1, 4] but should by [0, 56]
" [17, 30] - [18, 34] = [-1, -4] 
function! analog#time_diff(time1, time2)
    " Do not waste time calculating time differences between times on
    " different days
    if time1[2] != time2[2]
        return
    endif

    let temp = [a:time1[0] - a:time2[0], a:time1[1] - a:time2[1]]

    if temp[0] > 0 && temp[1] < 0
        let temp[0] -= 1
        let temp[1] += 60
    elseif temp[0] < 0 && temp[1] > 0
        let temp[0] += 1
        let temp[1] -= 60
    endif

    return temp
endfunction

function! analog#time_in_interval(time, intervals)
    let [cur_hours, cur_mins] = a:time

    for i in range(0, len(a:intervals) - 1, 2)
        let [min_hour, min_mins] = split(a:intervals[i], ':')
        let [max_hour, max_mins] = split(a:intervals[i + 1], ':')

        " TODO: Fix checks
        if cur_hours > min_hour && cur_hours < max_hour
            return i / 2
            "if cur_mins >= min_mins && cur_mins <= max_mins
            "    return i
            "endif
        endif
    endfor
endfunction

function! analog#time_to_close()
    let analog_times = split(analog#get_open_hours()[-1], ':')
    let current_time = split(strftime('%H:%M'), ':')

    return analog#time_diff(analog_times, current_time)
endfunction
" }}}

" Notifications {{{
function! analog#notify()
    if has('mac') || has('macunix')
        let script_cmd = 'osascript -e "display notification \"Analog closes in 5 minutes\" with title \"vim-analog:\"'

        if len(g:analog#osx_notification_sound_name) > 0
            let script_cmd .= ' sound name \"' . g:analog#osx_notification_sound_name . '\"'
        endif

        let script_cmd .= '"'
        call system(script_cmd)
    endif
endfunction
" }}}

" Echo status {{{
" Yes: DiffAdd, No: WarningMsg
function! analog#echo_open_status()
    let state = analog#is_open_or_echoerr()

    if state != -1
        echo (state == 1 ? g:analog#coffee_symbol : g:analog#no_coffee_symbol)
    endif
endfunction

function! analog#echo_staff()
    if analog#is_open_or_echoerr() > 0
        let staff = analog#get_staff()
        let hours = analog#get_open_hours()
        
        for i in range(0, len(staff) - 1)
            let s = join(staff[i], ', ')
            let from = hours[i * 2]
            let to = hours[i * 2 + 1]

            echo printf("%s (%s - %s)", s, from, to)
        endfor
    endif
endfunction

function! analog#echo_current_staff()
    if analog#is_open_or_echoerr() > 0
        let staff = analog#get_current_staff()

        echo join(staff, ', ')
    endif
endfunction

function! analog#echo_open_hours()
    if analog#is_open_or_echoerr() > 0
        let hours = analog#get_open_hours()

        for i in range(0, len(hours) - 1, 2)
            echo printf("%s - %s", hours[i], hours[i + 1])
        endfor
    endif
endfunction
" }}}

if g:analog#use_vim_airline || g:analog#use_vim_lightline
    if has('nvim')
        " Seems like neovim does not yet have periodic timers
        " See https://github.com/neovim/neovim/issues/140://github.com/neovim/neovim/issues/1404
    else
        " We have to rely on the CursorHold autocommand in regular vim
        " WARNING: This modifies 'updatetime' (see ':h updatetime')!
        "execute 'setlocal updatetime=' . g:analog#update_interval
        augroup analog_statusbar_update
           "autocmd!
            autocmd CursorHold * call analog#update()
        augroup END
    endif
endif

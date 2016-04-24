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

" General {{{
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

function! analog#get_staff()
    let json = analog#web#request(g:analog#web#shifts_url, '')

    return analog#json#parse_json_employees(json)
endfunction

function! analog#get_current_staff()
    let json = analog#web#request(g:analog#web#shifts_url, '')
    let staff = analog#json#parse_json_employees(json)
    let hours = analog#json#parse_json_open_hours(json)
    let i = analog#time#in_interval(split(strftime('%H:%M'), ':'), hours)

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

function! analog#get_all_matches(str, pattern)
    let results = []
    call substitute(a:str, a:pattern, '\=add(results, submatch(0))', 'g')

    return results
endfunction

function! analog#print_error_message(format, args)
   echohl WarningMsg
   "echoerr printf(a:format, a:args*)
   echohl NONE
endfunction

function! analog#get_current_symbol()
    return [g:analog#no_coffee_symbol, g:analog#coffee_symbol, g:analog#no_connection_symbol][analog#is_open()]
endfunction
" }}}

" Echo status {{{
" Yes: DiffAdd, No: WarningMsg
function! analog#echo_open_status()
    echo analog#get_current_symbol()
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

function! analog#echo_time_to_close()
    if analog#is_open_or_echoerr() > 0
        let diff = analog#time#time_to_close()

        echo printf("Analog closes in %s hour(s) and %s minute(s)", diff[0], diff[1])
    endif
endfunction
" }}}

" vim: foldmethod=marker

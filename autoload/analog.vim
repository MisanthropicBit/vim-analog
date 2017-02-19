" Web URLs {{{
let g:analog#web#base_url = 'https://analogio.dk/publicshiftplanning/api/%s/analog'
let g:analog#web#open_url = printf(g:analog#web#base_url, 'open')
let g:analog#web#shifts_url = printf(g:analog#web#base_url, 'shifts')
let g:analog#web#shifts_today_url = printf(g:analog#web#base_url, 'shifts/today')
" }}}

" Queries {{{
" Return the current version of vim-analog
function! analog#version()
    return g:analog#version
endfunction

" Return 1 if Analog is open, 0 if closed or -1 if a problem
" occured such as missing or malformed data
function! analog#is_open()
    let json = analog#web#request(g:analog#web#open_url, '')

    if empty(json)
        return -1
    endif

    return analog#json#parse_open_status(json)
endfunction

" Check if Analog is open or warn the user
function! analog#is_open_or_echoerr()
    let state = analog#is_open()

    if state == 0
        if g:analog#ignore_closed
            return 1
        endif

        call analog#warn("Analog is closed")
    elseif state == -1
        call analog#warn("No connection, or service is unavailable")
    endif

    return state
endfunction

" Get a list of names of the staff working at Analog today
function! analog#get_staff()
    let json = analog#web#request(g:analog#web#shifts_today_url, '')

    return analog#json#parse_json_employees(json)
endfunction

" Get a list of names of the staff working at Analog right now
function! analog#get_current_staff()
    let json = analog#web#request(g:analog#web#shifts_today_url, '')

    return analog#json#parse_employees(json, 'checkedInEmployees')
endfunction

" Get today's opening hours of Analog as a 2 element list of the opening
" and closing time
function! analog#get_open_hours()
    let json = analog#web#request(g:analog#web#shifts_today_url, '')

    return analog#json#parse_open_hours(json)
endfunction

" Collect all regex matches in a string and return them in a list
function! analog#get_all_matches(str, pattern)
    let results = []
    call substitute(a:str, a:pattern, '\=add(results, submatch(0))', 'g')

    return results
endfunction

" Return the symbol for Analog's current open status
function! analog#get_symbol(state)
    return [g:analog#no_coffee_symbol,
           \g:analog#coffee_symbol,
           \g:analog#no_connection_symbol][a:state]
endfunction

" Issue a highlighted warning message
function! analog#warn(msg)
    echohl WarningMsg
    echo "vim-analog: " . a:msg
    echohl NONE
endfunction
" }}}

" Echo commands {{{
" Echo if Analog is open or not
function! analog#echo_open_status()
    let state = analog#is_open_or_echoerr()

    echo analog#get_symbol(state)
endfunction

" Echo the staff working in Analog today along with opening hours
function! analog#echo_staff_and_hours()
    let json = analog#web#request(g:analog#web#shifts_today_url, '')
    let staff = analog#json#parse_employees(json, 'employees')

    if empty(staff)
        call analog#warn("Analog is closed")
        return
    endif

    let hours = analog#json#parse_open_hours(json)

    echo printf("%s (%s - %s)", join(staff, ", "), hours[0], hours[1])
endfunction

" Echo Analog's current staff
function! analog#echo_current_staff()
    let staff = analog#get_current_staff()

    if empty(staff)
        call analog#warn("Analog is closed")
    else
        echo join(staff, ', ')
    endif
endfunction

" Echo Analog's opening hours
function! analog#echo_open_hours()
    let hours = analog#get_open_hours()

    if empty(hours)
        call analog#warn("Analog is closed")
    else
        echo printf("%s - %s", hours[0], hours[1])
    endif
endfunction

" Echo the remaining time that Analog is open
function! analog#echo_time_to_close()
    let diff = analog#time#time_to_close()

    if empty(diff)
        call analog#warn("Analog is closed")
    else
        if diff[0] < 0 || diff[1] < 0
            echo printf("Analog closed %s hour(s) and %s minute(s) ago", diff[0], diff[1])
        else
            echo printf("Analog closes in %s hour(s) and %s minute(s)", diff[0], diff[1])
        endif
    endif
endfunction
" }}}

" vim: foldmethod=marker

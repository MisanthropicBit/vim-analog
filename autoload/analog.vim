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
        call analog#warn("Analog is closed")
    elseif state == -1
        call analog#warn("No connection, or service is unavailable")
    endif

    return state
endfunction

" Get today's opening hours of Analog as a 2 element list of the opening
" and closing time
function! analog#get_open_hours()
    let json = analog#web#request(g:analog#web#shifts_today_url, '')

    return analog#json#parse_open_hours(json)
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
    let maxlen = max(map(copy(staff), 'strchars(join(v:val, ", "))'))

    for i in range(len(staff))
        let names = join(staff[i], ", ")

        echo printf("%s%s(%s - %s)",
                   \names,
                   \repeat(' ', maxlen - strchars(names) + 1),
                   \hours[i][0], hours[i][1])
    endfor
endfunction

" Echo Analog's current staff
function! analog#echo_current_staff()
    let json = analog#web#request(g:analog#web#shifts_today_url, '')
    let staff = analog#json#parse_employees(json, 'employees')

    if empty(staff)
        call analog#warn("Analog is closed")
        return
    endif

    let hours = analog#json#parse_open_hours(json)
    let current_time = analog#time#now()
    let idx = index(map(copy(hours), 'analog#time#in_interval(' . string(current_time) . ', v:val)'), 1)

    if idx == -1
        call analog#warn("Analog is closed")
        return
    endif

    echo join(staff[idx], ', ')
endfunction

" Echo Analog's opening hours
function! analog#echo_open_hours()
    let hours = analog#get_open_hours()

    if empty(hours)
        call analog#warn("Analog is closed")
        return
    endif

    echo join(map(hours, "v:val[0] . ' - ' . v:val[1]"), "\n")
endfunction

" Echo the remaining time that Analog is open
function! analog#echo_time_to_close()
    let hours = analog#get_open_hours()
    let diff = analog#time#time_to_close(hours)

    if empty(diff)
        call analog#warn("Analog is closed")
    else
        if diff[0] < 0 || diff[1] < 0
            echo printf("Analog closed %s hour(s) and %s minute(s) ago",
                        \abs(diff[0]),
                        \abs(diff[1]))
        else
            echo printf("Analog closes in %s hour(s) and %s minute(s)", diff[0], diff[1])
        endif
    endif
endfunction
" }}}

" vim: foldmethod=marker

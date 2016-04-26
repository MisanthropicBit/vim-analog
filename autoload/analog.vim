" Web URLs {{{
let g:analog#web#base_url = 'www.cafeanalog.dk/api'
let g:analog#web#open_url = g:analog#web#base_url . '/open'
let g:analog#web#shifts_url = g:analog#web#base_url . '/shifts/today'
" }}}

" General {{{
function! analog#is_open()
    let json = analog#web#request(g:analog#web#open_url, '')

    if len(json) == 0
        return -1
    endif

    let state = analog#json#parse_open_status(json)

    if state == -1
        call analog#print_error_message("vim-analog: Unknown state for open: '%s'", state)
    endif

    return state
endfunction

function! analog#is_open_or_echoerr()
    let state = analog#is_open()

    if state == 0
        if g:analog#ignore_closed
            return 1
        endif

        call s:warn("Analog is closed")
    elseif state == -1
        call s:warn("No connection")
    endif

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

    return analog#json#parse_json_open_hours(json)
endfunction

function! analog#get_all_matches(str, pattern)
    let results = []
    call substitute(a:str, a:pattern, '\=add(results, submatch(0))', 'g')

    return results
endfunction

function! analog#get_current_symbol()
    return [g:analog#no_coffee_symbol, g:analog#coffee_symbol, g:analog#no_connection_symbol][analog#is_open()]
endfunction

function! s:warn(msg)
    echohl WarningMsg
    echo a:msg
    echohl NONE
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

        if diff[0] < 0 || diff[1] < 0
            echo printf("Analog closed %s hour(s) and %s minute(s) ago", diff[0], diff[1])
        else
            echo printf("Analog closes in %s hour(s) and %s minute(s)", diff[0], diff[1])
        endif
    endif
endfunction
" }}}

" vim: foldmethod=marker

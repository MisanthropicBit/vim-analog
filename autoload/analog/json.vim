" Patterns {{{
let g:analog#patterns#json_open = '\v^\{\"open\":(false|true)\}$'
let g:analog#patterns#json_employees = '\v\"Employees\":\[\zs(.{-})\ze\]'
let g:analog#patterns#json_open_hours = '\v\"%(Open|Close)\":\"\zs(.{-})\ze\"'
let g:analog#patterns#json_time = '\v\d{4}-\d{2}-\d{2}T\zs\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
let g:analog#patterns#json_full_date = '\v\zs\d{4}-\d{2}-\d{2}T\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
" }}}

function! analog#json#parse_open_status(json)
    let result = matchlist(a:json, g:analog#patterns#json_open)

    if len(result) > 1
        return (result[1] ==# "true" ? 1 : 0)
    endif

    return -1
endfunction

function! analog#json#parse_json_employees(json)
    let results = analog#get_all_matches(a:json, g:analog#patterns#json_employees)

    return map(map(results, 'substitute(v:val, "\"", "", "g")'), 'split(v:val, ",")')
endfunction

function! analog#json#parse_json_open_hours(json)
    let hours = analog#get_all_matches(a:json, g:analog#patterns#json_open_hours)
    let intervals = []

    for h in hours
        call add(intervals, matchstr(h, g:analog#patterns#json_time))
    endfor

    return intervals
endfunction

let s:has_json_functions = exists('*json_encode') && exists('json_decode')

if !s:has_json_functions
    " Patterns {{{
    let g:analog#patterns#json_open = '\v^\{\"open\":(false|true)\}$'
    let g:analog#patterns#json_employees = '\v\"Employees\":\[\zs(.{-})\ze\]'
    let g:analog#patterns#json_open_hours = '\v\"%(Open|Close)\":\"\zs(.{-})\ze\"'
    let g:analog#patterns#json_time = '\v\d{4}-\d{2}-\d{2}T\zs\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
    let g:analog#patterns#json_full_date = '\v\zs\d{4}-\d{2}-\d{2}T\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
    " }}}
endif

function! analog#json#parse_open_status(json)
    if s:has_json_functions
        let result = json_decode(a:json)

        if has_key(result, 'open')
            return (result.open ==# v:true ? 1 : 0)
        endif
    else
        let result = matchlist(a:json, g:analog#patterns#json_open)

        if len(result) > 1
            return (result[1] ==# "true" ? 1 : 0)
        endif
    endif

    return -1
endfunction

function! analog#json#parse_json_employees(json)
    if s:has_json_functions
        let result = json_decode(a:json)
        let employees = []

        for r in result
            if has_key(r, 'Employees')
                add(employees, r.Employees)
            else
                echoerr "vim-analog: Failed to parse json for employees"
                return []
            endif
        endfor
    else
        let results = analog#get_all_matches(a:json, g:analog#patterns#json_employees)

        return map(map(results, 'substitute(v:val, "\"", "", "g")'), 'split(v:val, ",")')
    endif
endfunction

function! analog#json#parse_json_open_hours(json)
    let intervals = []

    if s:has_json_functions
        let result = json_decode(a:json)

        for r in result
            if has_key(r, 'Open') && has_key(r, 'Close')
                add(intervals, [r.Open, r.Close])
            else
                echoerr "vim-analog: Failed to parse json for open hours"
                return []
            endif
        endfor
    else
        let hours = analog#get_all_matches(a:json, g:analog#patterns#json_open_hours)

        for h in hours
            call add(intervals, matchstr(h, g:analog#patterns#json_time))
        endfor
    endif

    return intervals
endfunction

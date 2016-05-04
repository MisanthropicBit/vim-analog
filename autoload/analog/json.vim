let s:has_json_decode = exists('*json_decode')
let s:pattern_json_time = '\v\d{4}-\d{2}-\d{2}T\zs\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'

if !s:has_json_decode
    " Patterns {{{
    let s:pattern_json_open = '\v^\{\"open\":(false|true)\}$'
    let s:pattern_json_open = '\v^\{\"open\":(false|true)\}$'
    let s:pattern_json_employees = '\v\"Employees\":\[\zs(.{-})\ze\]'
    let s:pattern_json_open_hours = '\v\"%(Open|Close)\":\"\zs(.{-})\ze\"'
    let s:pattern_json_full_date = '\v\zs\d{4}-\d{2}-\d{2}T\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
    " }}}
endif

function! analog#json#parse_open_status(json)
    if s:has_json_decode
        try
            let result = json_decode(a:json)
        catch
            return -2
        endtry

        if has_key(result, 'open')
            if result.open == v:true || result.open == v:false
                return (result.open ==# v:true ? 1 : 0)
            endif
        endif
    else
        let result = matchlist(a:json, s:pattern_json_open)

        if len(result) > 1
            return (result[1] ==# "true" ? 1 : 0)
        endif
    endif

    return result
endfunction

function! analog#json#parse_json_employees(json)
    if s:has_json_decode
        try
            let result = json_decode(a:json)
        catch
            return -1
        endtry

        let employees = []

        for r in result
            if has_key(r, 'Employees')
                call add(employees, r.Employees)
            else
                echoerr "vim-analog: Failed to parse json for employees"
                return []
            endif
        endfor

        return employees
    else
        let results = analog#get_all_matches(a:json, s:pattern_json_employees)

        return map(map(results, 'substitute(v:val, "\"", "", "g")'), 'split(v:val, ",")')
    endif
endfunction

function! analog#json#parse_json_open_hours(json)
    let intervals = []

    if s:has_json_decode
        try
            let result = json_decode(a:json)
        catch
            return -1
        endtry

        for r in result
            if has_key(r, 'Open') && has_key(r, 'Close')
                let interval = [matchstr(r.Open, s:pattern_json_time), matchstr(r.Close, s:pattern_json_time)]
                call extend(intervals, interval)
            else
                echoerr "vim-analog: Failed to parse json for open hours"
                return []
            endif
        endfor
    else
        let hours = analog#get_all_matches(a:json, s:pattern_json_open_hours)

        for h in hours
            call add(intervals, matchstr(h, s:pattern_json_time))
        endfor
    endif

    return intervals
endfunction

let s:has_json_decode = exists('*json_decode')
let s:pattern_json_time = '\v\d{4}-\d{2}-\d{2}T\zs\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'

if !s:has_json_decode
    let s:pattern_json_open = '\v^\{\"open\":\s*(false|true)\}$'
    let s:pattern_json_open = '\v^\{\"open\":\s*(false|true)\}$'
    let s:pattern_json_employees = '\v\"Employees\":\s*\[\zs(.{-})\ze\]'
    let s:pattern_json_open_hours = '\v\"%(Open|Close)\":\s*\"\zs(.{-})\ze\"'
    let s:pattern_json_full_date = '\v\zs\d{4}-\d{2}-\d{2}T\d{2}:\d{2}\ze:\d{2}%(\+|-)\d{2}:\d{2}'
endif

function! analog#json#parse_open_status(json)
    if s:has_json_decode
        try
            let result = json_decode(a:json)
        catch
            return -1
        endtry

        if type(result) == v:t_dict && has_key(result, 'open')
            if result.open == v:true || result.open == v:false
                return (result.open ==# v:true ? 1 : 0)
            endif
        endif

        return -1
    else
        let result = matchlist(a:json, s:pattern_json_open)

        if len(result) > 1
            return (result[1] ==# "true" ? 1 : 0)
        endif

        return -1
    endif

    return result
endfunction

function! analog#json#parse_json_employees(json)
    let error_msg = "vim-analog: Failed to parse json for employees"
    let employees = []

    if s:has_json_decode
        try
            let result = json_decode(a:json)
        catch /^Vim\%((\a\+)\)\=:E474/
            echoerr error_msg . " (" . v:exception . ")"
            return []
        endtry

        if type(result) == v:t_list
            for r in result
                if type(r) == v:t_dict && has_key(r, 'Employees')
                    call add(employees, r.Employees)
                else
                    echoerr error_msg
                endif
            endfor
        else
            " Result was not a list
            echoerr error_msg
        endif

        return employees
    else
        if empty(a:json)
            echoerr error_msg
        endif

        let employees = analog#get_all_matches(a:json, s:pattern_json_employees)

        return map(map(employees, 'substitute(v:val, "\"", "", "g")'), 'split(v:val, ",")')
    endif
endfunction

function! analog#json#parse_json_open_hours(json)
    let intervals = []

    if s:has_json_decode
        try
            let result = json_decode(a:json)
        catch
            return []
        endtry

        if type(result) == v:t_list
            for r in result
                if type(r) == v:t_dict && has_key(r, 'Open') && has_key(r, 'Close')
                    let interval = [matchstr(r.Open, s:pattern_json_time), matchstr(r.Close, s:pattern_json_time)]
                    call extend(intervals, interval)
                else
                    echoerr "vim-analog: Failed to parse json for open hours"
                    return []
                endif
            endfor
        endif
    else
        let hours = analog#get_all_matches(a:json, s:pattern_json_open_hours)

        for h in hours
            call add(intervals, matchstr(h, s:pattern_json_time))
        endfor

        " The intervals must be a pair of opening and closing times
        if len(intervals) % 2 != 0
            echoerr "vim-analog: Failed to parse json for open hours"
        endif
    endif

    return intervals
endfunction

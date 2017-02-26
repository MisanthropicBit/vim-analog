let s:has_json_decode = exists('*json_decode')
let s:pattern_json_time = '\v\d{4}-\d{2}-\d{2}T\zs\d{2}:\d{2}\ze:\d{2}'
let s:json_support_msg = "vim-analog requires json_decode (at least patch 7.4.1154)"

function! analog#json#parse_open_status(json)
    if !s:has_json_decode
        echoerr s:json_support_msg
        return -1
    endif

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
endfunction

function! analog#json#parse_employee(employee)
    if has_key(a:employee, 'firstName') && has_key(a:employee, 'lastName')
        return a:employee.firstName . " " . a:employee.lastName
    endif

    return ""
endfunction

function! analog#json#parse_employees(json, employee_type)
    let error_msg = "Failed to parse json for employees"
    let employees = []

    if !s:has_json_decode
        echoerr s:json_support_msg
        return []
    endif

    try
        let result = json_decode(a:json)
    catch /^Vim\%((\a\+)\)\=:E474/
        echoerr "vim-analog: " . error_msg . " (" . v:exception . ")"
        return []
    endtry

    if type(result) != v:t_list
        " Result was not a list
        call analog#warn(error_msg)
        return []
    endif

    for r in result
        if type(r) == v:t_dict && has_key(r, a:employee_type)
            let temp = []

            for e in r.employees
                let employee = analog#json#parse_employee(e)

                if empty(employee)
                    call analog#warn(error_msg)
                    return []
                endif

                call add(temp, employee)
            endfor

            call add(employees, temp)
        else
            call analog#warn(error_msg)
        endif
    endfor

    return employees
endfunction

function! analog#json#parse_open_hours(json)
    let intervals = []

    if !s:has_json_decode
        echoerr s:json_support_msg
        return []
    endif

    try
        let result = json_decode(a:json)
    catch
        return []
    endtry

    if type(result) == v:t_list
        for r in result
            if type(r) == v:t_dict && has_key(r, 'start') && has_key(r, 'end')
                let interval = [matchstr(r.start, s:pattern_json_time),
                                \matchstr(r.end, s:pattern_json_time)]
                call add(intervals, interval)
            else
                echoerr "vim-analog: Failed to parse json for open hours"
                return []
            endif
        endfor
    endif

    return intervals
endfunction

" JSON parsing {{{
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
" }}}

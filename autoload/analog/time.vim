" Get the current time in hours and minutes
function! analog#time#now()
    return split(strftime('%H:%M'), ':')
endfunction

" Get the difference in hours and minutes between two timepoints
function! analog#time#diff(from, to)
    " Do not waste time calculating time differences between times on
    " different days
    "if a:time1[2] != a:time2[2]
    "    return
    "endif

    let seconds1 = a:from[0] * 60 * 60 + a:from[1] * 60
    let seconds2 = a:to[0] * 60 * 60 + a:to[1] * 60
    let diff = seconds2 - seconds1

    return [diff / 60 / 60, diff / 60 % 60]
endfunction

" Return 1 if the time lies in the given interval, 0 otherwise
function! analog#time#in_interval(time, interval)
    let [cur_hours, cur_mins] = a:time
    let seconds = cur_hours * 60 * 60 + cur_mins * 60

    let [min_hour, min_mins] = split(a:interval[0], ':')
    let [max_hour, max_mins] = split(a:interval[1], ':')
    let minseconds = min_hour * 60 * 60 + min_mins * 60
    let maxseconds = max_hour * 60 * 60 + max_mins * 60

    return seconds >= minseconds && seconds <= maxseconds
endfunction

" Calculate the hours and minutes until Analog closes
function! analog#time#time_to_close(hours)
    if empty(a:hours)
        return []
    endif

    let current_time = analog#time#now()
    let analog_times = split(a:hours[-1][1], ':')

    return analog#time#diff(current_time, analog_times)
endfunction

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

" Return the index in the list of intervals which includes a given timepoint
function! analog#time#in_interval(time, intervals)
    let [cur_hours, cur_mins] = a:time
    let seconds = cur_hours * 60 * 60 + cur_mins * 60

    for i in range(0, len(a:intervals) - 1, 2)
        let [min_hour, min_mins] = split(a:intervals[i], ':')
        let [max_hour, max_mins] = split(a:intervals[i + 1], ':')
        let minseconds = min_hour * 60 * 60 + min_mins * 60
        let maxseconds = max_hour * 60 * 60 + max_mins * 60

        if seconds >= minseconds && seconds <= maxseconds
            return i / 2
        endif
    endfor

    return -1
endfunction

" Calculate the hours and minutes until Analog closes
function! analog#time#time_to_close()
    let temp = analog#get_open_hours()

    if empty(temp)
        return []
    endif

    let current_time = split(strftime('%H:%M'), ':')
    let analog_times = split(analog#get_open_hours()[-1], ':')

    return analog#time#diff(current_time, analog_times)
endfunction

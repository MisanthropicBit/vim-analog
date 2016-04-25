function! analog#time#diff(time1, time2)
    " Do not waste time calculating time differences between times on
    " different days
    "if a:time1[2] != a:time2[2]
    "    return
    "endif

    let temp = [a:time1[0] - a:time2[0], a:time1[1] - a:time2[1]]
    let seconds1 = a:time1[0] * 60 * 60 + a:time1[1] * 60
    let seconds2 = a:time2[0] * 60 * 60 + a:time2[1] * 60
    let diff = seconds2 - seconds1

    return [diff / 60 / 60, diff / 60 % 60]

    return temp
endfunction

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

function! analog#time#time_to_close()
    let analog_times = split(analog#get_open_hours()[-1], ':')
    let current_time = split(strftime('%H:%M'), ':')

    return analog#time#diff(analog_times, current_time)
endfunction

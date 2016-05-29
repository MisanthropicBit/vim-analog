function! analog#time#time_to_seconds(time)
    if len(a:time) == 2
        return a:time[0] * 60 * 60 + a:time[1] * 60
    endif

    echoerr printf("vim-analog: Cannot convert invalid time '%s' to seconds", string(a:time))
endfunction

function! analog#time#seconds_to_time(seconds)
    return [a:seconds / 60 / 60, a:seconds / 60 % 60]
endfunction

function! analog#time#diff(from, to)
    let seconds1 = analog#time#time_to_seconds(a:from)
    let seconds2 = analog#time#time_to_seconds(a:to)
    let diff = seconds2 - seconds1

    return analog#time#seconds_to_time(diff)
endfunction

function! analog#time#in_interval(time, intervals)
    let seconds = analog#time#time_to_seconds(a:time)

    for i in range(0, len(a:intervals) - 1, 2)
        let minseconds = analog#time#time_to_seconds(split(a:intervals[i], ':'))
        let maxseconds = analog#time#time_to_seconds(split(a:intervals[i + 1], ':'))

        if seconds >= minseconds && seconds <= maxseconds
            return i / 2
        endif
    endfor

    return -1
endfunction

function! analog#time#time_to_close()
    let temp = analog#get_open_hours()

    if empty(temp)
        return []
    endif

    let current_time = split(strftime('%H:%M'), ':')
    let analog_times = split(analog#get_open_hours()[-1], ':')

    return analog#time#diff(current_time, analog_times)
endfunction

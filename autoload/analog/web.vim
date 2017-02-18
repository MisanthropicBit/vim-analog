if exists('g:analog#web_autoloaded')
    finish
endif

function! s:AnalogCurlRequest(url, options)
    return system("curl -s --max-time 1 " . a:url)
endf

function! s:AnalogWgetRequest(url, options)
    return system("wget -q --timeout=1 -O - " . a:url)
endfunction

function! s:AnalogWebRequestMissing(url, options)
    echoerr "vim-analog: Either curl or wget must be installed"
    return ''
endfunction

" TODO: Add support for python
if executable('curl')
    let s:AnalogWebRequest = function("s:AnalogCurlRequest")
elseif executable('wget')
    let s:AnalogWebRequest = function("s:AnalogWgetRequest")
else
    let s:AnalogWebRequest = function("s:AnalogWebRequestMissing")
endif

" Request data from the given url with curl or wget
function! analog#web#request(url, options)
    " Use user supplied command
    if !empty(g:analog#query_command)
        return system(g:analog#query_command)
    endif

    if g:analog#query_command_preference == 'curl'
        return s:AnalogCurlRequest(a:url, a:options)
    elseif g:analog#query_command_preference == 'wget'
        return s:AnalogWgetRequest(a:url, a:options)
    elseif !empty(g:analog#query_command_preference)
        call analog#warn(printf("Unsupported command: %s", g:analog#query_command_preference))
        return ''
    endif

    return s:AnalogWebRequest(a:url, a:options)
endfunction

let g:analog#web_autoloaded = 1

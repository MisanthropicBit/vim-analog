if exists('g:analog#web_autoloaded')
    finish
endif

function! s:AnalogCurlRequest(url, options)
    return system("curl -s " . a:url)
endf

function! s:AnalogWgetRequest(url, options)
    echo "Using wget"
    return system("wget -qO - " . a:url)
endfunction

" TODO: Add support for python
if executable('curl')
    let s:AnalogWebRequest = function("s:AnalogCurlRequest")
elseif executable('wget')
    let s:AnalogWebRequest = function("s:AnalogWgetRequest")
endif

function! analog#web#request(url, options)
    return s:AnalogWebRequest(a:url, a:options)
endfunction

let g:analog#web_autoloaded = 1

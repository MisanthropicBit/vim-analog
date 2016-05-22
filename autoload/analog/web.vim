if exists('g:analog#web_autoloaded')
    finish
endif

function! s:AnalogCurlRequest(url, options)
    return system("curl -s " . a:url)
endf

function! s:AnalogWgetRequest(url, options)
    return system("wget -qO - " . a:url)
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

function! analog#web#request(url, options)
    return s:AnalogWebRequest(a:url, a:options)
endfunction

let g:analog#web_autoloaded = 1

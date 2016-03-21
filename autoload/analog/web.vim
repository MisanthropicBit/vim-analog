if exists('g:analog#web_autoloaded')
    finish
endif

"let analog#web#request = ''

function! s:AnalogCurlRequest(url, options)
    return system("curl -s " . a:url)
endf

if executable('curl')
    let s:AnalogWebRequest = function("s:AnalogCurlRequest")
endif

function! analog#web#request(url, options)
    return s:AnalogWebRequest(a:url, a:options)
endfunction

let g:analog#web_autoloaded = 1

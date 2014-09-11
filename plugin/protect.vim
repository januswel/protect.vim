" vim plugin file
" Filename:     protect.vim
" Maintainer:   janus_wel <janus.wel.3@gmail.com>
" License:      MIT License {{{1
"   See under URL.  Note that redistribution is permitted with LICENSE.
"   https://github.com/januswel/protect.vim/blob/master/LICENSE

" preparation {{{1
" check if this plugin is already loaded or not
if exists('loaded_protect')
    finish
endif
let loaded_protect = 1

" check vim has required features
if !has('autocmd')
    finish
endif

" reset the value of 'cpoptions' for portability
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" main {{{1
" commands {{{2
if exists(':ProtectFiles') != 2
    command -nargs=0 ProtectFiles call <SID>ProtectFiles()
endif

" constants {{{2
let s:protect_option_variables = {
            \   'readonly':       'g:protect_readonly_paths',
            \   'nomodifiable':   'g:protect_nomodifiable_paths',
            \ }
lockvar s:protect_option_variables

let s:protect_option_variables_default = {
            \   'readonly': [
            \       '/var/run/**',
            \       '$VIM/**',
            \       '$INCLUDE/**',
            \   ],
            \   'nomodifiable': [
            \       '/var/run/**',
            \       '$VIM/**',
            \       '$INCLUDE/**',
            \   ],
            \ }
lockvar s:protect_option_variables_default


let s:str_delimiter = '\s*,\s*'
lockvar s:str_delimiter

" function {{{2
function! s:GetValueOfVar(varname)
    if !exists(a:varname)
        throw 'Not exist: ' . a:varname
    endif

    return eval(a:varname)
endfunction

function! s:Convert2String(src)
    " check the type
    let typeofsrc = type(a:src)
    if     typeofsrc ==# 1 " String
        return join(split(a:src, s:str_delimiter), ',')
    elseif typeofsrc ==# 3 " List
        return join(a:src, ',')
    elseif typeofsrc ==# 4 " Dictionary
        return join(values(a:src), ',')
    endif

    throw 'A String, a List or a Dictionary is required: ' . string(a:src)
endfunction

function! s:ProtectFiles()
    augroup protect
        autocmd! protect
    augroup END

    for [opt, var] in items(s:protect_option_variables)
        try
            if exists(var)
                let paths = s:Convert2String(s:GetValueOfVar(var))
            else
                let paths = s:Convert2String(s:protect_option_variables_default[opt])
            endif
        catch
            continue
        endtry
        if !empty(paths)
            augroup protect
                execute 'autocmd' 'BufReadPost' paths 'setlocal' opt
            augroup END
        endif
    endfor
endfunction

" execute codes {{{2
call s:ProtectFiles()

" post-processing {{{1
" restore the value of 'cpoptions'
let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" }}}1
" vim: ts=4 sw=4 sts=0 et fdm=marker fdc=3

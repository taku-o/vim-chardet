" plugin loading guard {{{ {{{
scriptencoding utf8
if &cp || exists("g:loaded_chardet")
    finish
endif
let g:loaded_chardet = 1

" escape user environment.
let s:save_cpo = &cpo
set cpo&vim " }}}

" function! s:LoadPython() {{{
" load python module
function! s:LoadPython()
    " search python module path
    for l:i in split(globpath(&runtimepath, "python/chardet/__init__.py"), '\n')
        let l:add_pythonpath = fnamemodify(l:i, ":p:h:h")
    endfor

    " add to PYTHONPATH
    python << EOF
from vim import *
import vim
import site
site.addsitedir(vim.eval('l:add_pythonpath'))
EOF
endfunction " }}}

" function! g:Chardet() {{{
" return file encoding
" if is not file, or failed to detet encoding then, return ''
function! g:Chardet(...)
    if len(a:000) > 0
        let l:current_file = a:1
    else
        let l:current_file = expand('%')
    endif
    " if is not file then, return ''
    if filereadable(l:current_file)
    else
        return ''
    endif

    " load python module
    call s:LoadPython()

    python << EOF
from vim import *
import vim
import chardet
from chardet.universaldetector import UniversalDetector

# file path
current_file = vim.eval('l:current_file')

# detect encoding
detector = UniversalDetector()
for line in file(current_file, 'rb'):
    detector.feed(line)
    if detector.done:
        break
detector.close()

# encoding
encoding = detector.result['encoding']
vim.command("let l:detect_encoding = '%s'" % encoding)
EOF

    if l:detect_encoding == ''
        return ''
    endif

    return l:detect_encoding
endfunction " }}}

" command DetectFileEncoding {{{
" display detected file encoding
command! -nargs=? -complete=file DetectFileEncoding :echo "FILE ENCODING : " . g:Chardet(<f-args>)
" }}}

" clear plugin status {{{
let &cpo = s:save_cpo
finish " }}} }}}
==============================================================================
chardet.vim : detect file encoding. (python required)
------------------------------------------------------------------------------
$VIMRUNTIMEPATH/plugin/detect.vim
$VIMRUNTIMEPATH/python/chardet/*.py
==============================================================================
author  : OMI TAKU
url     : http://nanasi.jp/
email   : mail@nanasi.jp
==============================================================================

Display file encoding with command ':DetectFileEncoding'.

------------------------------------------------------------------------------
INSTALLATION

1. Unzip chardet.zip, and copy to 'plugin', 'python' directory in
   your 'runtimepath' directory.

    $HOME/vimfiles/plugin or $HOME/.vim/plugin
    -  detect.vim

    $HOME/vimfiles/python or $HOME/.vim/python
    -  chardet/*.py

2. Restart vim editor.


------------------------------------------------------------------------------
USAGE

Use command ':DetectFileEncoding',
and so Vim Editor diplay detected file encoding.

:DetectFileEncoding
    detect and display current file encoding.

:DetectFileEncoding {filepath}
    detect and display selected file encoding.


------------------------------------------------------------------------------
COMMAND EXAMPLE

:DetectFileEncoding
    detect and display current file encoding.

:DetectFileEncoding test.txt
    detect and display 'test.txt' file encoding.


==============================================================================
" vim: set et ft=vim nowrap foldmethod=marker :

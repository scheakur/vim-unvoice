"=============================================================================
" vim-unvoice - Create entries for Day One app from Vim
" Copyright (c) 2013 Scheakur <http://scheakur.com/>
"
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! unvoice#shout(text)
	if !executable('godayone')
		call s:show_error()
		return 0
	endif

	if empty(a:text)
		call s:open_window()
		return 0
	endif

	call s:write(a:text)
	return 1
endfunction


" internal functions {{{
let s:buf_nr = -1

function! s:show_error()
	echohl Error
	echomsg 'unvoice.vim needs `godayone` command.'
	echomsg 'Installation:'
	echomsg '> go get github.com/scheakur/godayone'
	echohl None
endfunction


function! s:open_window()
	if !bufexists(s:buf_nr)
		belowright 5new
		file `="[Unvoice]"`
		let s:buf_nr = bufnr('%')
		call feedkeys('i', 'n')
	elseif bufwinnr(s:buf_nr) == -1
		belowright 5split
		execute s:buf_nr . 'buffer'
		call feedkeys('i', 'n')
	elseif bufwinnr(s:buf_nr) != bufwinnr('%')
		execute bufwinnr(s:buf_nr) . 'wincmd w'
	endif

	setlocal filetype=unvoice
	setlocal bufhidden=delete
	setlocal buftype=nofile
	setlocal noswapfile
	setlocal nobuflisted
	setlocal modifiable

	command! -buffer -nargs=0 UnvoiceWrite  call <SID>shout()

	nnoremap <buffer> <silent> <C-CR>  :UnvoiceWrite<CR>
	inoremap <buffer> <silent> <C-CR>  <ESC>:UnvoiceWrite<CR>
	nnoremap <buffer> q  <C-w>c

	autocmd BufHidden <buffer> call let <SID>buf_nr = -1

	redraw!
endfunction


function! s:write(text)
	call system('godayone ' . s:quote_escape(a:text))
endfunction


function! s:shout()
	let text = join(getbufline('%', 1, '$'), "\n")
	call s:write(text)

	let on_shout = get(g:, 'unvoice_after_shout', 'close')

	if on_shout ==# 'clear'
		call feedkeys('ggdG', 'n')
	else
		call feedkeys("\<C-w>c", 'n')
	endif
endfunction


function! s:quote_escape(text)
	let escaped = substitute(a:text, '"', '\\"', 'g')
	return '"' . escaped . '"'
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

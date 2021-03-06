set nocompatible
set nobackup
set relativenumber
set undofile
set visualbell
set ttyfast

" regex search
nnoremap / /\v
vnoremap / /\v

" global subst
set gdefault

set wildchar=<Tab> wildmenu wildmode=full
set wildcharm=<C-Z>
nnoremap <F5> :b <C-Z>

nnoremap ; :
let mapleader = ','
let maplocalleader = ','
syntax on
set modelines=5
set popt=paper:letter

fun SetupVAM()
	set runtimepath+=~/.vim/addons/vim-addon-manager
	" commenting try .. endtry because trace is lost if you use it.
	" There should be no exception anyway
	" try
	call vam#ActivateAddons(['Solarized','snipmate-snippets','LaTeX_Box','Command-T','tcomment','EasyMotion','The_NERD_tree','taglist'], {'auto_install' : 0})
	"call vam#ActivateAddons(['snipmate-snippets','vim-latex','Command-T','Color_Sampler_Pack','The_NERD_tree'], {'auto_install' : 0})
	" pluginA could be github:YourName see vam#install#RewriteName()
	" catch /.*/
	"  echoe v:exception
	" endtry
endf
call SetupVAM()
" experimental: run after gui has been started (gvim) [3]
" option1:  au VimEnter * call SetupVAM()
" option2:  au GUIEnter * call SetupVAM()
" See BUGS sections below [*]

"call pathogen#runtime_append_all_bundles()
"call pathogen#helptags()

" can switch to other buffer if current buffer is modified
set hidden

set dy=lastline

" use :cd %:h instead
"if exists('+autochdir')
"	set autochdir
"endif

"set textwidth=78
set ts=4
set backspace=indent,eol,start
"set number " for line number
set sw=4
set smarttab
set showmatch
"" expand tab but not for makefiles
"set et
"autocmd BufNewFile,BufRead Makefile :set noet

set fileencodings=utf-8,gbk,ucs-bom,latin1

" if &t_Co == 256
" endif
if has("gui_running")
	colorscheme wombat256
else
	set t_Co=256
	colorscheme wombat256
	" set background=light
	" let g:solarized_termcolors=256
	" colorscheme solarized
endif
if has("gui_macvim")
    set transparency=10
	let macvim_hig_shift_movement = 1
    " swipe is broken in Lion
	" nmap <SwipeLeft> :bN<CR>
	" nmap <SwipeRight> :bn<CR>
endif

set guioptions+=aAce

set colorcolumn=80
set cindent
set formatoptions=tqn
set cino=g0:0(0

set incsearch
set hlsearch
set ignorecase
set smartcase
"clear highlighted search
nmap <silent> <leader><space>  :nohlsearch<cr>

" use tab to match parentheses
nnoremap <tab> %
vnoremap <tab> %

"set guitablabel=%N\ %f

" for gui
if has('mac')
    " set guifont=Anonymous\ Pro:h13
	set guifont=Consolas:h14
else
    set guifont=Monospace\ 10
endif

set laststatus=2
"set statusline=%n\ %1*%h%f%*\ %=%<[%3lL,%2cC]\ %2p%%\ 0x%02B%r%m
set statusline=%-3.3n%f\[%{strlen(&ft)?&ft:'none'}]%=%-14(%l,%c%V%)%<%P

au BufNewFile,BufRead *.r setf r
au BufNewFile,BufRead *.r set syntax=r

"set list
"set listchars=tab:▸\ 

" format paragraph
nnoremap <leader>q gwip
" select previously pasted stuff
nnoremap <leader>v V`]
" create vertical split and switch to that window
nnoremap <leader>w <C-w>v<C-w>l
" move around
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" easy tcomment
nmap <leader>c <c-_><c-_>
" easy motion
let g:EasyMotion_leader_key = '<Leader>m'
" for Command-T
"let g:CommandTMaxFiles=500

filetype plugin on
"set shellslash
filetype indent on

au filetype tex set sw=2 ts=2

"let g:tex_flavor = 'pdflatex'
let g:Tex_CompileRule_pdf = 'pdflatex -interaction=nonstopmode $*'
let g:Tex_MultipleCompileFormats='pdf'

au FileType c,cpp  set et sw=4 ts=4 cindent cino=g0:0(0 fo=tcroqn
au FileType python set et sw=4 ts=4 complete+=k~/.vim/syntax/python.vim 
set tags=tags;/

map <F2> :NERDTreeToggle<CR>

" use gnu global to replace cscope
set cscopetag
set cscopeprg=gtags-cscope
set cscopequickfix=c-,d-,e-,f-,g0,i-,s-,t-
"nmap <silent> <leader>j <ESC>:cstag <c-r><c-w><CR>
"nmap <silent> <leader>g <ESC>:lcs f c <c-r><c-w><cr>:lw<cr>
"nmap <silent> <leader>s <ESC>:lcs f s <c-r><c-w><cr>:lw<cr>
"command! -nargs=+ -complete=dir FindFiles :call FindFiles(<f-args>)
"au VimEnter * call VimEnterCallback()
"au BufAdd *.[ch] call FindGtags(expand('<afile>'))
"au BufWritePost *.[ch] call UpdateGtags(expand('<afile>'))

function! FindFiles(pat, ...)
    let path = ''
    for str in a:000
        let path .= str . ','
    endfor

    if path == ''
        let path = &path
    endif

    echo 'finding...'
    redraw
    call append(line('$'), split(globpath(path, a:pat), '\n'))
    echo 'finding...done!'
    redraw
endfunc

function! VimEnterCallback()
    for f in argv()
        if fnamemodify(f, ':e') != 'c' && fnamemodify(f, ':e') != 'h'
            continue
        endif

        call FindGtags(f)
    endfor
endfunc

function! FindGtags(f)
    let dir = fnamemodify(a:f, ':p:h')
    while 1
        let tmp = dir . '/GTAGS'
        if filereadable(tmp)
            exe 'cs add ' . tmp . ' ' . dir
            break
        elseif dir == '/'
            break
        endif

        let dir = fnamemodify(dir, ":h")
    endwhile
endfunc

function! UpdateGtags(f)
    let dir = fnamemodify(a:f, ':p:h')
    exe 'silent !cd ' . dir . ' && global -u &> /dev/null &'
endfunc


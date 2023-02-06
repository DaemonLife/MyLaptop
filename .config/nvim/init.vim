let g:plugged_home = '~/.config/nvim/plugged'

" Plugins List
call plug#begin(g:plugged_home)

" My plugins
" Plug 'preservim/nerdtree'
Plug 'junegunn/goyo.vim'
Plug 'reedes/vim-pencil'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tomtom/tcomment_vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'mzlogin/vim-markdown-toc'
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
Plug 'vimwiki/vimwiki'

" syntax check
Plug 'w0rp/ale'

" Autocomplete
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-jedi'

" Formater
Plug 'Chiel92/vim-autoformat'

call plug#end()

filetype plugin on
" Configurations Part

" Others
" set clipboard=unnamedplus
"set spell spelllang=ru_ru,en_us
map <F8> :setlocal spell! spelllang=ru,en_us<CR>
"Можно добавлять слова в словарь, используя zg или удалять, используя zug
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
set nocompatible
set noerrorbells
set novisualbell
set history=200

"wrap заставляет переносить строчки без их разделения
"Соответсвенно nowrap рендерит строчки за границами экрана
set wrap linebreak nolist "Данная вариация работает как wrap...
"... но переносит строчки не посимвольно, а по словам

set linebreak
set ruler
set autoindent
set foldcolumn=0
" set columns=80
set number relativenumber

" UI configuration
syntax on
syntax enable
set cursorline
set scrolloff=6

" colorscheme
colorscheme material
let g:material_terminal_italics = 1
set background=dark
let g:lightline = {
            \ 'colorscheme': 'one',
            \ }
" True Color Support if it's avaiable in terminal
if has("termguicolors")
    set termguicolors
endif

" if has("gui_running")
" set guicursor=n-v-c-sm:block,i-ci-ve:block,r-cr-o:blocks
" endif

" set number
" set relativenumber
set hidden
set mouse=a
set noshowmode
set noshowmatch
set nolazyredraw

" Turn off backup
set nobackup
set noswapfile
set nowritebackup

" Search configuration
set ignorecase                    " ignore case when searching
set smartcase                     " turn on smartcase

" Tab and Indent configuration
set expandtab
set tabstop=4
set shiftwidth=4

" vim-autoformat
noremap <F3> :Autoformat<CR>

" NCM2
augroup NCM2
    autocmd!
    " enable ncm2 for all buffers
    autocmd BufEnter * call ncm2#enable_for_buffer()
    " :help Ncm2PopupOpen for more information
    set completeopt=noinsert,menuone,noselect
    " When the <Enter> key is pressed while the popup menu is visible, it only
    " hides the menu. Use this mapping to close the menu and also start a new line.
    " inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
    " uncomment this block if you use vimtex for LaTex
    " autocmd Filetype tex call ncm2#register_source({
    "           \ 'name': 'vimtex',
    "           \ 'priority': 8,
    "           \ 'scope': ['tex'],
    "           \ 'mark': 'tex',
    "           \ 'word_pattern': '\w+',
    "           \ 'complete_pattern': g:vimtex#re#ncm2,
    "           \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
    "           \ })
augroup END

" Ale
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_linters = {'python': ['flake8']}

" Airline
let g:airline_left_sep  = ''
let g:airline_right_sep = ''
let g:airline#extensions#ale#enabled = 1
let airline#extensions#ale#error_symbol = 'E:'
let airline#extensions#ale#warning_symbol = 'W:'

" Goyo
map <F9> :Goyo<CR>  
map <F10> :PencilSoft<CR>
let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'
let g:pencil#autoformat = 1      " 0=disable, 1=enable (def)
" Pencil
augroup pencil
    autocmd!
    autocmd FileType markdown,mkd call pencil#init()
    autocmd FileType text         call pencil#init()
augroup END

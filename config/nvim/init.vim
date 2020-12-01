set nocompatible
filetype off
set runtimepath+=~/.config/nvim/dein/repos/github.com/Shougo/dein.vim/

call dein#begin(expand('~/.config/nvim/dein/'))

call dein#add('Shougo/dein.vim')

"-----------------------------------------------------------------------------------
"Vim-airline
call dein#add('bling/vim-airline')

"theme
call dein#add('vim-airline/vim-airline-themes')

"startscreen
call dein#add('mhinz/vim-startify')

"color
call dein#add('ap/vim-css-color')
call dein#add('kabbamine/vcoolor.vim')


"-----------------------------------------------------------------------------------
"nerdtree
call dein#add('scrooloose/nerdtree', {'on_cmd': 'NERDTreeToggle'})

"deoplete
"call dein#add('Shougo/deoplete.nvim')
"if !has('nvim')
"  call dein#add('roxma/nvim-yarp')
"  call dein#add('roxma/vim-hug-neovim-rpc')
"endif
"call dein#add('zchee/deoplete-jedi', {'on_ft': ['python']})
"call dein#add('deoplete-plugins/deoplete-clang')

"neomake
"call dein#add('neomake/neomake')

"coc
call dein#add('neoclide/coc.nvim', {'branch': 'release'})

"echodoc
call dein#add('Shougo/echodoc.vim')
let g:echodoc#type = 'virtual'

"-----------------------------------------------------------------------------------
"Other usability stuff
call dein#add('jiangmiao/auto-pairs')
call dein#add('ntpeters/vim-better-whitespace')
call dein#add('farmergreg/vim-lastplace')


"-----------------------------------------------------------------------------------
call dein#end()
filetype plugin indent on
syntax enable
set encoding=utf-8

"-----------------------------------------------------------------------------------
"vim-airline
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_powerline_fonts = 1
function! AirlineInit()
        let g:airline_section_z = airline#section#create(['%l/%L %c'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()
let g:airline_theme='term'



"deoplete
"let g:deoplete#enable_at_startup = 1
"neomake
"let g:neomake_python_enabled_makers = ['flake8']
"deoplete-clang
"let g:deoplete#sources#clang#libclang_path = "/usr/lib64/libclang.so"
"let g:deoplete#sources#clang#clang_header = "/usr/lib64/clang"


"echodoc
let g:echodoc_enable_at_startup = 1

"-----------------------------------------------------------------------------------
:imap jk <Esc>

map <C-J> :bnext<CR>
map <C-K> :bprev<CR>
map <C-L> :tabn<CR>
map <C-H> :tabp<CR>
map <C-n> :NERDTreeToggle<CR>


if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif


"-----------------------------------------------------------------------------------


set undodir=~/.config/nvim/.undo/
set backupdir=~/.config/nvim/.backup/
set undofile

set number
set clipboard+=unnamedplus
set completeopt-=preview

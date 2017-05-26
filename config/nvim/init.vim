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
call dein#add('Shougo/deoplete.nvim')
call dein#add('zchee/deoplete-jedi', {'on_ft': ['python']})
call dein#add('zchee/deoplete-go', {'build': 'make'}, {'on_ft': ['python']})

"neomake
call dein#add('neomake/neomake')

"echodoc
call dein#add('Shougo/echodoc.vim')


"-----------------------------------------------------------------------------------
"Other usability stuff
call dein#add('jiangmiao/auto-pairs')
call dein#add('ntpeters/vim-better-whitespace')
call dein#add('farmergreg/vim-lastplace')


"-----------------------------------------------------------------------------------
call dein#end()
filetype plugin indent on
syntax enable


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
let g:deoplete#enable_at_startup = 1
let g:python_host_prog = '/home/pierre/Packages/neovim/neovim3/bin/python'
let g:python3_host_prog = '/home/pierre/Packages/neovim/neovim3/bin/python'
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'

"neomake
let g:neomake_python_enabled_makers = ['flake8']

"echodoc
let g:echodoc_enable_at_startup = 1


"-----------------------------------------------------------------------------------
"automatically install new plugins
if dein#check_install()
    call dein#install()
endif


"-----------------------------------------------------------------------------------
:imap jk <Esc>

map <C-J> :bnext<CR>
map <C-K> :bprev<CR>
map <C-L> :tabn<CR>
map <C-H> :tabp<CR>
map <C-n> :NERDTreeToggle<CR>


"-----------------------------------------------------------------------------------
set undodir=~/.config/nvim/.undo/
set backupdir=~/.config/nvim/.backup/
set undofile

set number
set clipboard+=unnamedplus
set completeopt-=preview
set noshowmode
set lazyredraw
set hidden
set noswapfile
set ignorecase
set smartcase
set hlsearch
set magic
set showmatch
set number
set numberwidth=2

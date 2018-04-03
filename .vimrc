source ~/mswin.vim

syntax on
filetype plugin indent on

"persistent undo
set undodir=~/.vim/undo/
set undofile
set undolevels=1000
set undoreload=10000

set hlsearch                          " Highlight search results
set ignorecase smartcase              " Search queries intelligently set case
set incsearch                         " Show search results as you type

set autoread                          " Auto reload changed files
set wildmenu                          " Tab autocomplete in command mode

set number            " Enable line numbers


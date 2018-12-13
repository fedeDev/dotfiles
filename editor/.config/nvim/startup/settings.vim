" To be loaded from our vimrc/init.nvim.

" General/misc. settings
" Fortran variables that control syntax h-lighting. Set before turning on stax.
let fortran_free_source = 1
let fortran_do_enddo = 1
let fortran_more_precise = 1

filetype plugin indent on
syntax on
set ignorecase          " Ignore, mostly, case mismatches for searching.
set smartcase           " but become case sensitive intelligently.
set switchbuf=useopen   " When switching bufer jump to the first window with it.
set hidden              " Allows making buffers hidden with unsaved changes.
set undolevels=3500     " Use many, many levels of undo.
set mouse=a             " Enable mouse in all modes.
set mousemodel=extend   " Right mouse click extends selection.
set shortmess+=cF       " Avoid the 'hit enter to continue' messages.
set inccommand=split    " When using, e.g., :%s, preview changes to buffer
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem

" Set C-indentation to follow facebook's viper C++ style.
set expandtab                " Turn a tab into spaces
set tabstop=2                " Number of spaces a tab counts for
set shiftwidth=2             " Spaces for autoindents
set softtabstop=2
" Don't allow neovim to set tabstops to 8 (PEP8).
" let g:python_recommended_style = 0
set shiftround               " Makes indenting a multiple of shiftwidth
set smartindent
set cinoptions=l1,g1,h1,E-s,N-s,t0,i4,+4,(0,w1,W4
set colorcolumn=+1
set textwidth=100

" Visual options.
set noshowmode                   " Don't show the mode (" -- INSERT -- ").
set cursorline                   " Highlights the current line.
set number                       " Show line numbers.
set completeopt=menu,menuone,noinsert,noselect
" TODO add something to extends to listchars :)
set listchars=tab:›\ ,eol:¬      " Characters for tab and CR in list mode
set linebreak                    " If wrap is on (tex[t] files) break at word.
set breakindent                  " Wraped lines are aligned horizontally.
set showbreak=↳\                 " If wrap-broke line, start with ↳ .
 
" Auto generated files options.
set undofile                     " Stores undo state even when files are closed.
set undodir^=~/.config/nvim/undo " Folder needs to exist.
set nobackup                     " No backup~ files.
set noswapfile                   " Don't use swaps.
set wildmode=longest,full        " Command window completion behavior.
set nomodeline                   " Google vim modeline vulnerability.

" Environment characteristics.
set fileformat=unix          " File mode is unix.
set fileformats=unix,dos,mac " Detect unix, dos, mac file formats in that order.
set clipboard=unnamedplus,unnamed

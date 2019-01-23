" GeneralSettings {{{
  if ! &diff
    if has('autocmd')
      " Open files allways in new tabs
      au VimEnter * tab all
      " Make vim remember the line where you were the last time
      au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    endif
  endif

  if has('syntax') && !exists('g:syntax_on')
    syntax enable
  endif

  " GUI options:
  "set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar

  " Use :help 'option' to see the documentation for the given option.
  set autoread
  set autoindent
  set smartindent
  set backspace=indent,eol,start
  set complete-=i
  set showmatch
  set showmode
  set smarttab
  set scrolloff=1
  if !&diff
    set cursorline
  endif

  set nrformats-=octal
  set shiftround

  " Folding
  set foldmarker={{{,}}}
  set foldlevelstart=99
  set foldmethod=marker

  " set clipboard=unnamedplus
  set clipboard=unnamed
  set regexpengine=1
  set ttyfast
  set lazyredraw
  set ttimeout
  set ttimeoutlen=50
  set updatetime=250

  set laststatus=2
  set ruler
  set showcmd
  set wildmenu

  set encoding=utf-8
  set tabstop=2 shiftwidth=2 expandtab
  set listchars=tab:┊\ ,trail:▓ ",space:·,nbsp:␣,precedes:«,extends:»,eol:¬
  set list

  set number
  set incsearch
  set hlsearch
  set ignorecase
  set smartcase

  " In many terminal emulators the mouse works just fine, thus enable it.
  if has('mouse')
    set mouse=a
  endif

  " Enable (better) mouse support under tmux
  if &term =~ '^screen' && exists('$TMUX')
    set mouse+=a
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
    " tmux will send xterm-style keys when xterm-keys is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
    execute "set <xHome>=\e[1;*H"
    execute "set <xEnd>=\e[1;*F"
    execute "set <Insert>=\e[2;*~"
    execute "set <Delete>=\e[3;*~"
    execute "set <PageUp>=\e[5;*~"
    execute "set <PageDown>=\e[6;*~"
    execute "set <xF1>=\e[1;*P"
    execute "set <xF2>=\e[1;*Q"
    execute "set <xF3>=\e[1;*R"
    execute "set <xF4>=\e[1;*S"
    execute "set <F5>=\e[15;*~"
    execute "set <F6>=\e[17;*~"
    execute "set <F7>=\e[18;*~"
    execute "set <F8>=\e[19;*~"
    execute "set <F9>=\e[20;*~"
    execute "set <F10>=\e[21;*~"
    execute "set <F11>=\e[23;*~"
    execute "set <F12>=\e[24;*~"
  endif

  " do not history when leavy buffer
  set hidden

  set nobackup
  set nowritebackup
  set noswapfile
  set fileformats=unix,dos,mac

  set completeopt=menuone,longest,preview
" }}}
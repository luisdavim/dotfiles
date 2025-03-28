" Shortcuts {{{

  let mapleader = '\'

  " lazy ':'
  map ; :

  " Easier to exit terminal mode
  tnoremap <Esc> <C-\><C-n>

  " Don't use Ex mode, use Q for formatting
  map Q gq

  " Use <C-L> to clear the highlighting of :set hlsearch.
  if maparg('<C-L>', 'n') ==# ''
    nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
  endif

  inoremap <C-U> <C-G>u<C-U>

  " FIXME: (broken) ctrl s to save
  noremap  <C-s> :update<CR>
  vnoremap <C-s> <C-C>:update<CR>
  inoremap <C-s> <Esc>:update<CR>

  " exit insert mode
  inoremap <C-c> <Esc>

  " Find
  " map <C-f> /

  " indent / deindent after selecting the text with (⇧ v), (.) to repeat.
  vnoremap > >gv
  vnoremap < <gv
  nnoremap <Tab> >>_
  nnoremap <S-Tab> <<_
  inoremap <S-Tab> <C-D>
  vnoremap <Tab> >gv
  vnoremap <S-Tab> <gv

  " comment / decomment & normal comment behavior
  vmap <C-/> gc
  nnoremap <C-/> gcc
  inoremap <C-/> gcc
  " nmap <C-/>   <Plug>NERDCommenterToggle
  " vmap <C-/>   <Plug>NERDCommenterToggle<CR>gv
  " nmap <C-#>   <Plug>NERDCommenterToggle
  " vmap <C-#>   <Plug>NERDCommenterToggle<CR>gv

  " Text wrap simpler, then type the open tag or ',"
  vmap <C-w> S

  " Cut, Paste, Copy
  vmap <C-x> d
  vmap <C-v> p
  vmap <C-c> y
  nnoremap <F2> :set invpaste paste?<CR>
  " set pastetoggle=<F2>
  nnoremap <silent> <F2> :set paste!<cr>
  inoremap <silent> <F2> <esc>:set paste!<cr>i
  " Use a scratch file for clipboard
  "vmap <leader>y :w! /tmp/vitmp<CR>
  "nmap <leader>p :r! cat /tmp/vitmp<CR>
  vmap <leader>y "*y
  nmap <leader>p "*p

  " Undo, Redo (broken)
  nnoremap <C-z> :undo<CR>
  inoremap <C-z> <Esc>:undo<CR>
  nnoremap <C-y> :redo<CR>
  inoremap <C-y> <Esc>:redo<CR>
  nnoremap <F5>  :GundoToggle<CR>

  noremap <Leader>i :set list!<CR>

  nnoremap <Leader>p :set paste<CR>
  nnoremap <Leader>o :set nopaste<CR>
  noremap  <Leader>tb :TagbarToggle<CR>
  " noremap  <Leader>nt :NERDTreeToggle<CR>
  " noremap  <C-\> :NERDTreeToggle<CR>
  " nmap <C-n> :NERDTreeToggle<CR>
  " vmap ++ <plug>NERDCommenterToggle
  " nmap ++ <plug>NERDCommenterToggle
  nmap     <leader>TB <Plug>ToggleBrackets
  imap     <leader>TB <Plug>ToggleBrackets
  " noremap  <leader>co :diffoff!<CR><C-W><C-O>

  noremap <C-w>e :SyntasticCheck<CR>
  noremap <C-w>f :SyntasticToggleMode<CR>

  " Tabs {{{
  " Tab navigation
  nnoremap <S-PageUp>   :tabprevious<CR>
  inoremap <S-PageUp>   <Esc>:tabprevious<CR>i
  nnoremap <S-PageDown> :tabnext<CR>
  inoremap <S-PageDown> <Esc>:tabnext<CR>i
  "nnoremap <C-t>        :tabnew<CR>
  "inoremap <C-t>        <Esc>:tabnew<CR>i
  nnoremap <C-k>        :tabclose<CR>
  inoremap <C-k>        <Esc>:tabclose<CR>i
  nnoremap <S-h>        gT
  nnoremap <S-l>        gt

  " tab navigation like firefox
  " nnoremap <C-S-tab> :tabprevious<CR>
  " nnoremap <C-tab>   :tabnext<CR>
  " nnoremap <C-t>     :tabnew<CR>
  " inoremap <C-S-tab> <Esc>:tabprevious<CR>i
  " inoremap <C-tab>   <Esc>:tabnext<CR>i
  " inoremap <C-t>     <Esc>:tabnew<CR>
  " }}}

  "  Window management {{{
  nnoremap <Leader>sv :windo wincmd K<CR>
  nnoremap <Leader>sh :windo wincmd H<CR>
  " select a window with -
  nmap - <Plug>(choosewin)
  " resize windows ⇧ and the directional keys
  nnoremap <silent> <S-Left> :CmdResizeLeft<cr>
  nnoremap <silent> <S-Down> :CmdResizeDown<cr>
  nnoremap <silent> <S-Up> :CmdResizeUp<cr>
  nnoremap <silent> <S-Right> :CmdResizeRight<cr>
  " }}}

  " fugitive git bindings
  "vimdiff current vs git head (fugitive extension)
  nnoremap <Leader>gd :Gdiff<cr>
  nnoremap <Leader>gdm :Gdiff master<cr>
  "switch back to current file and closes fugitive buffer
  "nnoremap <Leader>gD :diffoff!<cr><c-w>h:bd<cr>
  nnoremap <Leader>gD <c-w>h<c-w>c
  nnoremap <Leader>ga :Git add %:p<CR><CR>
  nnoremap <Leader>gs :Git<CR>
  nnoremap <Leader>gc :Gcommit -v -q<CR>
  nnoremap <Leader>gt :Gcommit -v -q %:p<CR>
  nnoremap <Leader>ge :Gedit<CR>
  nnoremap <Leader>gr :Gread<CR>
  nnoremap <Leader>gw :Gwrite<CR><CR>
  nnoremap <Leader>gbl :Git blame<CR>
  nnoremap <Leader>gl :silent! Glog<CR>:bot copen<CR>
  nnoremap <Leader>gp :Git grep<Space>
  nnoremap <Leader>gm :Gmove<Space>
  nnoremap <Leader>gb :Git branch<Space>
  nnoremap <Leader>go :Git checkout<Space>
  nnoremap <Leader>gps :Dispatch! git push<CR>
  nnoremap <Leader>gpl :Dispatch! git pull<CR>
  nnoremap <Leader>g- :Silent Git stash<CR>:e<CR>
  nnoremap <Leader>g+ :Silent Git stash pop<CR>:e<CR>
  noremap  <Leader>g :GitGutterToggle<CR>

  " Vim Codex
  " nnoremap  <C-x> :CreateCompletion<CR>
  " inoremap  <C-x> <Esc>li<C-g>u<Esc>l:CreateCompletion<CR>

  " Vista
  noremap <space>v :Vista!!<CR>

  " Vimux Aliases
  command -nargs=+ Run :call VimuxRunCommand("<args>")
  command -nargs=* Prompt :call VimuxPromptCommand("<args>")
  command -nargs=* RootRunner :call VimuxRunCommand("cd " . FindRootDirectory().";clear;" . "<args>")
  command CloseRunner VimuxCloseRunner
  command ToggleRunner VimuxTogglePane
  command RunAgain VimuxRunLastCommand

  " Clap Maps to Ctrl-p {{{
  nnoremap <C-p> :Clap files<CR>
  nnoremap <C-o> :Clap filer<CR>
  nnoremap <C-e> :Clap command<CR>
  nnoremap <C-j> :Clap tags<CR>
  nnoremap <C-f> :Clap grep<CR>
  nnoremap <C-w>w :Clap windows<CR>
  nnoremap <C-w>b :Clap buffers<CR>

  nmap <Leader>c [clap]
  xmap <Leader>c [clap]

  nnoremap <silent> [clap]c :Clap coc_commands<CR>
  nnoremap <silent> [clap]co :Clap coc_outline<CR>
  nnoremap <silent> [clap]cs :Clap coc_symbols<CR>
  nnoremap <silent> [clap]cd :Clap coc_diagnostics<CR>
  nnoremap <silent> [clap]p :Clap files<CR>
  nnoremap <silent> [clap]o :Clap filer<CR>
  nnoremap <silent> [clap]t :Clap tags<CR>
  nnoremap <silent> [clap]T :Clap proj_tags<CR>
  nnoremap <silent> [clap]q :Clap quickfix<CR>
  nnoremap <silent> [clap]l :Clap loclist<CR>
  nnoremap <silent> [clap]gs :Clap git_diff_files<CR>
  nnoremap <silent> [clap]gr :Clap grep<CR>
  nnoremap <silent> [clap]* :Clap grep ++query=<cword><CR>
  xnoremap <silent> [clap]* :Clap grep ++query=@visual<CR>
  " }}}

  " coc FZF preview {{{
  nmap <Leader>z [fzf-p]
  xmap <Leader>z [fzf-p]

  nnoremap <silent> [fzf-p]p     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
  nnoremap <silent> [fzf-p]gs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
  nnoremap <silent> [fzf-p]ga    :<C-u>CocCommand fzf-preview.GitActions<CR>
  nnoremap <silent> [fzf-p]b     :<C-u>CocCommand fzf-preview.Buffers<CR>
  nnoremap <silent> [fzf-p]B     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
  nnoremap <silent> [fzf-p]o     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>
  nnoremap <silent> [fzf-p]<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
  nnoremap <silent> [fzf-p]g;    :<C-u>CocCommand fzf-preview.Changes<CR>
  nnoremap <silent> [fzf-p]/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
  nnoremap <silent> [fzf-p]*     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
  nnoremap          [fzf-p]gr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
  xnoremap          [fzf-p]gr    "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
  nnoremap <silent> [fzf-p]t     :<C-u>CocCommand fzf-preview.BufferTags<CR>
  nnoremap <silent> [fzf-p]q     :<C-u>CocCommand fzf-preview.QuickFix<CR>
  nnoremap <silent> [fzf-p]l     :<C-u>CocCommand fzf-preview.LocationList<CR>
  " }}}
" }}}

" PluginSettings {{{

  " FastFold
  let g:markdown_folding = 1
  let g:tex_fold_enabled = 1
  let g:vimsyn_folding = 'af'
  let g:xml_syntax_folding = 1
  let g:javaScript_fold = 1
  let g:sh_fold_enabled= 7
  let g:ruby_fold = 1
  let g:perl_fold = 1
  let g:perl_fold_blocks = 1
  let g:r_syntax_folding = 1
  let g:rust_fold = 1
  let g:go_fold = 1
  let g:php_folding = 1

  " tComment {{{
  " Disable tComment to escape some entities
  let g:tcomment#replacements_xml={}
  " }}}

  " nerdcommenter {{{
  " Add spaces after comment delimiters by default
  let g:NERDSpaceDelims = 1
  " Use compact syntax for prettified multi-line comments
  let g:NERDCompactSexyComs = 1
  " Align line-wise comment delimiters flush left instead of following code indentation
  let g:NERDDefaultAlign = 'left'
  " Set a language to use its alternate delimiters by default
  let g:NERDAltDelims_java = 1
  " Add your own custom formats or override the defaults
  " let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
  " Allow commenting and inverting empty lines (useful when commenting a region)
  let g:NERDCommentEmptyLines = 1
  " Enable trimming of trailing whitespace when uncommenting
  let g:NERDTrimTrailingWhitespace = 1
  " Enable NERDCommenterToggle to check all selected lines is commented or not
  let g:NERDToggleCheckAllLines = 1
  " }}}

  " nerdtree {{{
  if has('autocmd')
    au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    au FileType nerdtree syntax match hideBracketsInNerdTree "\]" contained conceal containedin=AL
    augroup nerdtreehidecwd
      autocmd!
      autocmd FileType nerdtree setlocal conceallevel=3
              \ | syntax match NERDTreeHideCWD #^[</].*$# conceal
              \ | setlocal concealcursor=n
    augroup end
  endif

  let g:NERDTreeIgnore = ['^node_modules$', '^vendor$']
  " let g:NERDTreeMapOpenInTab='<ENTER>'
  let g:NERDTreeQuitOnOpen = 1
  let g:NERDTreeMinimalUI = 1
  let g:NERDTreeDirArrows = 1

  let g:NERDTreeHijackNetrw = 0

  " let g:NERDTreeFileExtensionHighlightFullName = 1
  " let g:NERDTreeExactMatchHighlightFullName = 1
  " let g:NERDTreePatternMatchHighlightFullName = 1
  " let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
  " let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name

  " let g:NERDTreeSyntaxDisableDefaultExtensions = 1
  " let g:NERDTreeDisableExactMatchHighlight = 1
  " let g:NERDTreeDisablePatternMatchHighlight = 1
  " let g:NERDTreeSyntaxEnabledExtensions = ['c', 'h', 'c++', 'php', 'rb', 'js', 'css', 'go', 'py']

  let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✓",
    \ 'Ignored'   : "!",
    \ "Unknown"   : "?"
    \ }

  " sync open file with NERDTree
  " Check if NERDTree is open or active
  " function! IsNERDTreeOpen()
  "   return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
  " endfunction

  " Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
  " file, and we're not in vimdiff
  " function! SyncTree()
  "   if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
  "     NERDTreeFind
  "     wincmd p
  "   endif
  " endfunction

  " Highlight currently open buffer in NERDTree
  " autocmd BufEnter * call SyncTree()

  " }}}

  " vim-rooter {{{
  " if has('autocmd')
  "   " Set vim current working directory to the current project root
  "   autocmd VimEnter * if exists(":Rooter") | au BufEnter * :Rooter
  " endif
  let g:rooter_patterns = ['.git', '.hg', '.projections.json', 'requirements.txt', 'setup.cfg', 'package.json', 'go.mod', 'Makefile']
  " }}}

  " lf {{{
  " let g:lf_replace_netrw = 1 " open lf when vim open a directory
  let g:lf_map_keys = 0
  " }}}

  " vim-resize {{{
  let g:vim_resize_disable_auto_mappings = 1
  " }}}

  " vim-choosewin {{{
  let g:choosewin_overlay_enable = 1
  " }}}

  " matchparen {{{
  let g:matchparen_timeout = 2
  let g:matchparen_insert_timeout = 2
  " }}}

  " GeekNote {{{
  "let g:GeeknoteFormat="markdown"
  " }}}

  " Syntastic {{{
  let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes':   [],'passive_filetypes': [] }
  let g:syntastic_aggregate_errors = 1
  let g:syntastic_always_populate_loc_list = 0
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_go_checkers = ['go', 'golint', 'errcheck']
  " }}}

  " Gundu {{{
  " let g:gundo_width = 60
  " let g:gundo_preview_height = 40
  " let g:gundo_right = 1
  " }}}

  " MinMap {{{
  let g:minimap_highlight='Visual'
  " }}}

  " IndentLine {{{
  let g:indentLine_enabled = 0
  let g:indentLine_faster = 1
  if g:indentLine_faster == 0
    let g:indentLine_leadingSpaceEnabled = 1
  endif
  let g:vim_json_syntax_conceal = 0
  let g:indentLine_char = '┊'
  " let g:indentLine_char_list = ['|', '¦', '┆', '┊']
  let g:indentLine_leadingSpaceChar = '˰'
  let g:indentLine_noConcealCursor = ""
  " set conceallevel=1
  " let g:indentLine_conceallevel=1

  " Vim
  let g:indentLine_color_term = 239
  "GVim
  let g:indentLine_color_gui = '#4e4e4e'
  " none X terminal
  let g:indentLine_color_tty_light = 7 " (default: 4)
  let g:indentLine_color_dark = 1 " (default: 2)'
  " }}}

  " IndentBlankLine {{{
  let g:indent_blankline_disable_warning_message = 0
  " }}}

  " Conoline {{{
  " if !&diff
  "   let g:conoline_auto_enable = 1
  " endif
  " }}}

  " vim-illuminate {{{
  let g:Illuminate_ftblacklist = ['nerdtree', 'vim-plug', 'sixpack', '', 'qf']
  " let g:Illuminate_ftHighlightGroups = {
  "     \ 'vim': ['', 'Function', 'Constant', 'vimVar'],
  "     \ 'cpp': ['', 'Function', 'Constant']
  "     \ }
  " }}}

  " GitGutter {{{
  let g:gitgutter_max_signs = 500
  " let g:gitgutter_highlight_lines = 1
  " }}}

  " Ack {{{
  for command in ['Ack', 'AckAdd', 'AckFromSearch', 'LAck', 'LAckAdd', 'AckFile', 'AckHelp', 'LAckHelp', 'AckWindow', 'LAckWindow']
    exe 'command ' . substitute(command, 'Ack', 'Ag', "") . ' ' . command
  endfor

  " if executable('ag')
  "   let g:ackprg = 'ag --vimgrep'
  " endif
  if executable('rg')
    let g:ackprg = 'rg --vimgrep'
  endif
  " }}}

  " Ripgrep {{{
  let g:rg_command = 'rg --vimgrep -S'
  " }}}

  " CtrlSF {{{
  " nmap     <C-F>f <Plug>CtrlSFPrompt
  " vmap     <C-F>f <Plug>CtrlSFVwordPath
  " vmap     <C-F>F <Plug>CtrlSFVwordExec
  " nmap     <C-F>n <Plug>CtrlSFCwordPath
  " nmap     <C-F>p <Plug>CtrlSFPwordPath
  " nnoremap <C-F>o :CtrlSFOpen<CR>
  " nnoremap <C-F>t :CtrlSFToggle<CR>
  " inoremap <C-F>t <Esc>:CtrlSFToggle<CR>
  let g:ctrlsf_ackprg = 'rg'
  let g:ctrlsf_default_view_mode = 'compact'
  let g:ctrlsf_auto_close = { "normal" : 1, "compact": 1 }
  let g:ctrlsf_auto_focus = { "at": "start" }
  " }}}

  " vista {{{
  " Executive used when opening vista sidebar without specifying it.
  " See all the avaliable executives via `:echo g:vista#executives`.
  let g:vista_default_executive = 'coc'
  " }}}

  " clap-vim {{{
  let g:clap_preview_direction = 'UD'
  let g:clap_preview_size = 10
  let g:clap_layout = {'relative': 'editor', 'width': '67%', 'height': '15%', 'row': '15%', 'col': '17%'}
  let g:clap_open_action = { 'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit' }
  if has('nvim')
    let g:clap_popup_border = 'single'
  else
    let g:clap_popup_border = 'sharp'
  endif
  let g:clap_search_box_border_style = 'nil'
  " }}}

  " CtrlP {{{
  " Ignore some folders and files for CtrlP indexing
  let g:ctrlp_custom_ignore = {
    \ 'dir':  '\.git$\|\.yardoc\|node_modules\|log\|tmp$\|vendor',
    \ 'file': '\.so$\|\.dat$|\.DS_Store$'
    \ }

  "nnoremap <C-e> :CtrlPCmdPalette<CR>
  let g:ctrlp_cmdpalette_execute = 1

  let g:ctrlp_extensions = ['smarttabs']

  " If 1 will highlight the selected file in the tabline.
  let g:ctrlp_smarttabs_modify_tabline = 0
  " Reverse the order in which files are displayed.
  let g:ctrlp_smarttabs_reverse = 1
  " Exclude quickfix buffers.
  let g:ctrlp_smarttabs_exclude_quickfix = 0

  " Maps to Alt-p
  "nnoremap π :CtrlPSmartTabs<CR>

  " NOTE: The following should make CtrlP faster
  let g:ctrlp_match_window = 'bottom,order:ttb'
  let g:ctrlp_switch_buffer = 0
  let g:ctrlp_working_path_mode = 0
  " if executable('ag')
  "   set grepprg=ag\ --vimgrep
  "   let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
  "   let g:ctrlp_use_caching = 0
  " endif
  if executable('rg')
    set grepprg=rg\ --vimgrep
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    let g:ctrlp_use_caching = 0
  endif
  let g:ctrlp_working_path_mode = 'ra'
  " Always open files in new tabs
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }
  " }}}

  " Ultisnip {{{
  " NOTE: <f1> otherwise it overrides <tab> forever
  let g:UltiSnipsExpandTrigger = "<C-tab>"
  let g:UltiSnipsJumpForwardTrigger = "<C-tab>"
  let g:UltiSnipsJumpBackwardTrigger = "<C-S-tab>"
  let g:did_UltiSnips_vim_after = 1
  " }}}

  " YouCompleteMe {{{
  " make YCM compatible with UltiSnips (using supertab)
  let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
  let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
  let g:SuperTabDefaultCompletionType = '<C-n>'

  " let g:loaded_youcompleteme = 1 " Disable YCM
  let g:ycm_collect_identifiers_from_tags_files = 1 " Let YCM read tags from Ctags file
  let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
  let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
  let g:ycm_complete_in_comments = 1 " Completion in comments
  let g:ycm_complete_in_strings = 1 " Completion in string
  let g:ycm_add_preview_to_completeopt = 0
  let g:ycm_autoclose_preview_window_after_completion = 1
  let g:ycm_autoclose_preview_window_after_insertion = 1

  let g:complete_parameter_use_ultisnips_mapping = 1
  "inoremap <silent><expr> ( complete_parameter#pre_complete("()")
  "smap <c-j> <Plug>(complete_parameter#goto_next_parameter)
  "imap <c-j> <Plug>(complete_parameter#goto_next_parameter)
  "smap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
  "imap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
  " }}}

  " AutoPairs {{{
  "let g:AutoPairs = {'[':']', '{':'}',"'":"'",'"':'"', '`':'`'}
  "inoremap <buffer><silent> ) <C-R>=AutoPairsInsert(')')<CR>
  " }}}

  " Brackets {{{
  let g:usemarks = 0
  " }}}

  "vim-vue {{{
  let g:vue_pre_processors = []
  " }}}

  " Vim-go {{{
  "let g:go_gopls_enabled = 1
  let g:go_gopls_options = ['-remote=auto']
  " let g:go_def_mode='gopls'
  " let g:go_info_mode='gopls'
  " let g:go_referrers_mode = 'gopls'

  let g:go_fmt_autosave = 1
  let g:go_fmt_command = "goimports"
  " let g:go_fmt_options = '-w'

  " turn highlighting on
  let g:go_highlight_functions = 1
  let g:go_highlight_methods = 1
  let g:go_highlight_structs = 1
  " let g:go_highlight_types = 1
  " let g:go_highlight_extra_types = 1
  " let g:go_highlight_fields = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_build_constraints = 1

  "let g:go_auto_sameids = 1
  let g:go_auto_type_info = 1

  " disable vim-go :GoDef short cut (gd)
  " this is handled by LanguageClient [LC]
  " let g:go_def_mapping_enabled = 0

  " Open go doc in vertical window, horizontal, or tab
  " au Filetype go nnoremap <leader>v :vsp <CR>:exe 'GoDef' <CR>
  " au Filetype go nnoremap <leader>s :sp <CR>:exe 'GoDef'<CR>
  " au Filetype go nnoremap <leader>t :tab split <CR>:exe 'GoDef'<CR>
  " }}}

  " vimspector {{{
  " You can use 'VISUAL_STUDIO' or 'HUMAN'
  " Visual Studio config avoid to the mapping of <F3> key, sometimes used to map file explorer buffer.
  let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
  " mnemonic 'di' = 'debug inspect' (pick your own, if you prefer!)
  " for normal mode - the word under the cursor
  nmap <Leader>di <Plug>VimspectorBalloonEval
  " for visual mode, the visually selected text
  xmap <Leader>di <Plug>VimspectorBalloonEval
  " }}}

  " Codi {{{
  " Use pry instead of irb
  " let g:codi#interpreters = {
  " \ 'ruby': {
  "     \ 'bin': ['pry', '-f'],
  "     \ 'prompt': '^[\d\+] pry(\w\+). ',
  "     \ },
  " \ }
  " }}}

  " vim-airline {{{
  " let g:airline_extensions = ['branch', 'tabline', 'whitespace']
  let g:airline#extensions#branch#enabled = 1
  let g:airline#extensions#coc#enabled = 1
  let g:airline#extensions#vista#enabled = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffer_min_count = 1
  let g:airline#extensions#tabline#show_buffers = 0
  let g:airline#extensions#whitespace#enabled = 1
  let g:airline#extensions#whitespace#skip_indent_check_ft = {'go': ['mixed-indent-file']}
  let g:airline_powerline_fonts = 1
  " }}}

  " vim-floaterm {{{
  let g:floaterm_width = 0.8
  let g:floaterm_height = 0.5
  " }}}


  " neoterm {{{
  let g:neoterm_default_mod = 'horizontal'
  " }}}

" }}}

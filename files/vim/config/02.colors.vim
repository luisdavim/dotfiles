" ColorThemes {{{
  highlight clear
  set background=dark
  set bg=dark
  set t_Co=256

  " Overrides {{{
  " hi! link TreesitterContext CursorLine
  " hi! link TreesitterContextLineNumber CursorLineNr
  if has('autocmd')
    " if ! has('gui_macvim')
    "   au ColorScheme * hi! Normal ctermbg=none guibg=NONE
    "   au ColorScheme * hi! NonText ctermbg=none guibg=NONE
    " else
    "   set transparency=5
    " endif
    if g:os != 'Android'
      set fillchars+=vert:│   " add a bar for vertical splits
      " set fillchars=stl:-     " fill active window's statusline with -
      " set fillchars+=stlnc:-  " also fill inactive windows
    endif
    " au ColorScheme * hi VertSplit cterm=none ctermfg=Black ctermbg=none guibg=NONE

    " au ColorScheme * hi! Conceal ctermbg=none ctermfg=239  guibg=NONE guifg=#4e4e4e
    " au ColorScheme * hi! FoldColumn ctermbg=none ctermfg=none guibg=NONE
    " au ColorScheme * hi! Folded ctermbg=none guibg=NONE
    " au ColorScheme * hi! CursorLine ctermfg=none guifg=NONE gui=NONE term=NONE cterm=NONE
    " au ColorScheme * hi! CursorLineNr cterm=NONE
    au ColorScheme * hi! link illuminatedWord Visual

    " au ColorScheme * hi! link CocHighlightText CursorLine
    " au ColorScheme * hi! link illuminatedWord CursorLine
    " au ColorScheme * hi! link CocHighlightText Visual

    " au ColorScheme * hi! CocUnderline gui=undercurl term=undercurl
    " au ColorScheme * hi! CocErrorHighlight ctermfg=red guisp=red guifg=#c4384b gui=undercurl term=undercurl
    " au ColorScheme * hi! CocWarningHighlight ctermfg=yellow guisp=yellow guifg=#c4ab39 gui=undercurl term=undercurl

    " au ColorScheme * hi! link CocMenuSel PmenuSel
    " au ColorScheme * hi! link CocPumMenu Pmenu
    " au ColorScheme * hi! link CocPumVirtualText Comment

    " au ColorScheme *  hi! link CocFloating Pmenu
    " au ColorScheme *  hi! CocErrorFloat ctermfg={fg color} ctermbg={bg color} gui={gui color}

    au ColorScheme * hi! link ClapPreview Pmenu
    au ColorScheme * hi! link ClapDisplay Pmenu
    au ColorScheme * hi! link ClapSelected PmenuSel

    " typographic ligatures {{{
    " from: https://maximewack.com/post/emulating_ligatures/
    " if has('conceal')
    "   setlocal conceallevel=1
    "   " au Syntax * syntax clear customOperator

    "   " au Syntax * syntax match customOperator '\/' conceal cchar=÷
    "   " au Syntax * syntax match customOperator '*' conceal cchar=×
    "   au Syntax * syntax match customOperator '++' conceal cchar=⧺

    "   au Syntax * syntax match customOperator "=\@<!===\@!" conceal cchar=≖
    "   au Syntax * syntax match customOperator "=\@<!====\@!" conceal cchar=≡
    "   au Syntax * syntax match customOperator '\~=' conceal cchar=≃
    "   au Syntax * syntax match customOperator '==' conceal cchar=≣
    "   au Syntax * syntax match customOperator ':=' conceal cchar=≔
    "   au Syntax * syntax match customOperator '!=' conceal cchar=≠
    "   au Syntax * syntax match customOperator '!==' conceal cchar=≢
    "   au Syntax * syntax match customOperator '>=' conceal cchar=≥
    "   au Syntax * syntax match customOperator '!>=' conceal cchar=≱
    "   au Syntax * syntax match customOperator '<=' conceal cchar=≤
    "   au Syntax * syntax match customOperator '!<=' conceal cchar=≰

    "   au Syntax * syntax match customOperator '|>' conceal cchar=⊳
    "   au Syntax * syntax match customOperator '<|' conceal cchar=⊲
    "   au Syntax * syntax match customOperator '>>' conceal cchar=»
    "   au Syntax * syntax match customOperator '<<' conceal cchar=«
    "   " au Syntax * syntax match customOperator '\\' conceal cchar=λ

    "   au Syntax * syntax match customOperator '::' conceal cchar=∷
    "   au Syntax * syntax match customOperator '->' conceal cchar=→
    "   au Syntax * syntax match customOperator '=>' conceal cchar=⇒

    "   au Syntax * syntax match customOperator '||' conceal cchar=∨
    "   au Syntax * syntax match customOperator '&&' conceal cchar=∧
    "   au Syntax * syntax match customOperator '|=' conceal cchar=⊧
    "   " au Syntax * syntax match customOperator '|.' conceal cchar=⊦
    "   au Syntax * syntax match customOperator '/=' conceal cchar=≠

    "   au ColorScheme * hi link customOperator Operator
    "   au ColorScheme * hi! link Conceal Operator

    " endif
    " }}}
  endif
  " }}}

  " Use GIU colors
  if has("termguicolors")
    set termguicolors
  endif
  if !has("nvim")
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"
  endif

  let g:rainbow_active = 1

  " let g:minimap_highlight_range = 1
  let g:minimap_highlight_search = 1
  let g:minimap_git_colors = 1

  let base16colorspace=256
  set guifont=JetBrainsMono\ Nerd\ Font:h12

  " use a slightly darker background, like GitHub inline code blocks
  let g:github_colors_soft = 0
  " more blocky diff markers in signcolumn (e.g. GitGutter)
  let g:github_colors_block_diffmark = 0

  let g:gh_color = "soft"

  " let g:github_sidebars = ["qf", "vista_kind", "terminal", "packer"]
  " let g:github_transparent = 1

  let g:tokyonight_style = 'night' " available: night, storm
  let g:tokyonight_disable_italic_comment = 0
  let g:tokyonight_enable_italic = 1
  " let g:tokyonight_transparent_background = 1
  let g:tokyonight_current_word = 'underline' " available: 'bold', 'underline', 'italic', 'grey background'

  if has("nvim")
  let g:airline_theme = 'github_dark_high_contrast'
  else
  " let g:airline_theme = 'github'
  " let g:airline_theme = 'ghdark'
  let g:airline_theme = 'base16_black_metal'
  endif

  let g:lightline = { 'colorscheme': 'github' }
  " let g:lightline = {'colorscheme' : 'ghdark'}

  " let g:clap_theme = 'atom_dark'
  " let g:clap_theme = 'onehalfdark'

  if has("nvim")
    colorscheme github_dark_high_contrast
  else
    colorscheme ghdark
  endif

  " if has('nvim')
  "   set pumblend=5
  "   set winblend=5
  " endif

" }}}


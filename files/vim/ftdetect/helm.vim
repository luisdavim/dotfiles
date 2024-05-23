function! s:isHelm()
  let filepath = expand("%:p")
  let filename = expand("%:t")
  if filepath =~ '\v/(templates)/.*\.(ya?ml|gotmpl|tpl|txt)$' | return 1 | en
  if filename =~ '\v(helmfile).ya?ml' | return 1 | en
  " if getline(1) =~ '^apiVersion:' || getline(2) =~ '^apiVersion:' | return 1 | en
  " if !empty(findfile("Chart.yaml", expand('%:p:h').';')) | return 1 | en
  return 0
endfunction

au BufRead,BufNewFile * if s:isHelm() | set ft=helm | en

" Use {{/* */}} as comments
au FileType helm setlocal commentstring={{/*\ %s\ */}}

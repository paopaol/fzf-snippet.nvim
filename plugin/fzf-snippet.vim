if exists('g:loaded_fzf_snippet') | finish | endif

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

command! FzfSnippet lua require'fzf-snippet'.fzf_snip()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_fzf_snippet = 1

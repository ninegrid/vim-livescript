" Language:    Coco
" Maintainer:  satyr
" URL:         http://github.com/satyr/vim-coco
" License:     WTFPL

if exists('current_compiler')
  finish
endif

let current_compiler = 'co'
" Pattern to check if coco is the compiler
let s:pat = '^' . current_compiler

" Get a `makeprg` for the current filename. This is needed to support filenames
" with spaces and quotes, but also not break generic `make`.
function! s:GetMakePrg()
  return escape('coco -c' . g:coco_make_options    
  \                         . ' $* '                   
  \                         . fnameescape(expand('%')),
  \             ' ')                                   
endfunction

exec 'CompilerSet makeprg=' . s:GetMakePrg()

CompilerSet errorformat=%EFailed\ at:\ %f,
                       \%CSyntaxError:\ %m\ on\ line\ %l,
                       \%CError:\ Parse\ error\ on\ line\ %l:\ %m,
                       \%C,%C\ %.%#

" Compile the current file.
command! -bang -bar -nargs=* CocoMake make<bang> <args>

" Set `makeprg` on rename since we embed the filename in the setting.
augroup CocoUpdateMakePrg
  autocmd!

  " Update `makeprg` if coco is still the compiler, else stop running this
  " function.
  function! s:UpdateMakePrg()
    if &l:makeprg =~ s:pat
      let &l:makeprg = s:GetMakePrg()
    elseif &g:makeprg =~ s:pat
      let &g:makeprg = s:GetMakePrg()
    else
      autocmd! CocoUpdateMakePrg
    endif
  endfunction

  " Set autocmd locally if compiler was set locally.
  if &l:makeprg =~ s:pat
    autocmd BufFilePost,BufWritePost <buffer> call s:UpdateMakePrg()
  else
    autocmd BufFilePost,BufWritePost          call s:UpdateMakePrg()
  endif
augroup END

" Language:    Coco
" Maintainer:  satyr
" URL:         http://github.com/satyr/vim-coco
" License:     WTFPL

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=:#
setlocal commentstring=#\ %s

setlocal makeprg=coco\ -c\ $*\ '%'
setlocal errorformat=%EFailed\ at:\ %f,
                    \%CSyntaxError:\ %m\ on\ line\ %l,
                    \%CError:\ Parse\ error\ on\ line\ %l:\ %m,
                    \%C,%C\ %.%#

" Fold by indentation, but only if enabled.
setlocal foldmethod=indent

if !exists("coco_folding")
  setlocal nofoldenable
endif

if !exists("coco_make_options")
  let coco_make_options = ""
endif

" Compile snippet.
command! -range=% CocoCompile <line1>,<line2>:w !coco -scb

" Compile the current file.
function! s:CocoMake(bang, args)
  exec ('make' . a:bang) g:coco_make_options a:args fnameescape(expand('%'))
endfunction
command! -bang -bar -nargs=* CocoMake call s:CocoMake(<q-bang>, <q-args>)


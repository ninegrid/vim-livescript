" Language:    Coco
" Maintainer:  satyr
" URL:         http://github.com/satyr/vim-coco
" License:     WTFPL

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=f-1:###,:#
setlocal commentstring=#\ %s

" Fold by indentation, but only if enabled.
setlocal foldmethod=indent

if !exists("coco_folding")
  setlocal nofoldenable
endif

" Compile some CoffeeScript.
command! -range=% CocoCompile <line1>,<line2>:w !coco -scb

" Compile the current file on write.
if exists("coco_compile_on_save")
  autocmd BufWritePost,FileWritePost *.co silent !coco -c "<afile>" &
endif


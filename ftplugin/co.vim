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
setlocal omnifunc=javascriptcomplete#CompleteJS

" Extra options passed to CocoMake
if !exists("coco_make_options")
  let coco_make_options = ""
endif

" Enable CocoMake if it won't overwrite any settings.
if !len(&l:makeprg)
  compiler co
endif

" Reset the global variables used by CocoCompile.
function! s:CocoCompileResetVars()
  " Position in the source buffer
  let s:coco_compile_src_buf = -1
  let s:coco_compile_src_pos = []

  " Position in the CocoCompile buffer
  let s:coco_compile_buf = -1
  let s:coco_compile_win = -1
  let s:coco_compile_pos = []

  " If CocoCompile is watching a buffer
  let s:coco_compile_watch = 0
endfunction

" Save the cursor position when moving to and from the CocoCompile buffer.
function! s:CocoCompileSavePos()
  let buf = bufnr('%')
  let pos = getpos('.')

  if buf == s:coco_compile_buf
    let s:coco_compile_pos = pos
  else
    let s:coco_compile_src_buf = buf
    let s:coco_compile_src_pos = pos
  endif
endfunction

" Restore the cursor to the source buffer.
function! s:CocoCompileRestorePos()
  let win = bufwinnr(s:coco_compile_src_buf)

  if win != -1
    exec win 'wincmd w'
    call setpos('.', s:coco_compile_src_pos)
  endif
endfunction

" Close the CocoCompile buffer and clean things up.
function! s:CocoCompileClose()
  silent! autocmd! CocoCompileAuPos
  silent! autocmd! CocoCompileAuWatch

  call s:CocoCompileRestorePos()
  call s:CocoCompileResetVars()
endfunction

" Update the CocoCompile buffer given some input lines.
function! s:CocoCompileUpdate(startline, endline)
  let input = join(getline(a:startline, a:endline), "\n")

  " Coco doesn't like empty input.
  if !len(input)
    return
  endif

  " Compile input.
  let output = system('coco -scb 2>&1', input)

  " Move to the CocoCompile buffer.
  exec s:coco_compile_win 'wincmd w'

  " Replace buffer contents with new output and delete the last empty line.
  setlocal modifiable
    exec '% delete _'
    put! =output
    exec '$ delete _'
  setlocal nomodifiable

  " Highlight as JavaScript if there is no compile error.
  if v:shell_error
    setlocal filetype=
  else
    setlocal filetype=javascript
  endif

  " Restore the cursor in the compiled output.
  call setpos('.', s:coco_compile_pos)
endfunction

" Update the CocoCompile buffer with the whole source buffer and restore the
" cursor.
function! s:CocoCompileWatchUpdate()
  call s:CocoCompileSavePos()
  call s:CocoCompileUpdate(1, '$')
  call s:CocoCompileRestorePos()
endfunction

" Peek at compiled CocoScript in a scratch buffer. We handle ranges like this
" to prevent the cursor from being moved (and its position saved) before the
" function is called.
function! s:CocoCompile(startline, endline, args)
  " Don't compile the CocoCompile buffer.
  if bufnr('%') == s:coco_compile_buf
    return
  endif

  " Parse arguments.
  let watch = a:args =~ '\<watch\>'
  let unwatch = a:args =~ '\<unwatch\>'
  let vert = a:args =~ '\<vert\%[ical]\>'
  let size = str2nr(matchstr(a:args, '\<\d\+\>'))

  " Remove any watch listeners.
  silent! autocmd! CocoCompileAuWatch

  " If just unwatching, don't compile.
  if unwatch
    let s:coco_compile_watch = 0
    return
  endif

  if watch
    let s:coco_compile_watch = 1
  endif

  call s:CocoCompileSavePos()

  " Build the CocoCompile buffer if it doesn't exist.
  if s:coco_compile_buf == -1
    let src_win = bufwinnr(s:coco_compile_src_buf)

    " Create the new window and resize it.
    if vert
      let width = size ? size : winwidth(src_win) / 2

      vertical new
      exec 'vertical resize' width
    else
      " Try to guess the compiled output's height.
      let height = size ? size : min([winheight(src_win) / 2,
      \                               (a:endline - a:startline) * 2 + 4])

      botright new
      exec 'resize' height
    endif

    " Set up scratch buffer.
    setlocal bufhidden=wipe buftype=nofile
    setlocal nobuflisted nomodifiable noswapfile nowrap

    autocmd BufWipeout <buffer> call s:CocoCompileClose()
    nnoremap <buffer> <silent> q :hide<CR>

    " Save the cursor position on each buffer switch.
    augroup CocoCompileAuPos
      autocmd BufEnter,BufLeave * call s:CocoCompileSavePos()
    augroup END

    let s:coco_compile_buf = bufnr('%')
    let s:coco_compile_win = bufwinnr(s:coco_compile_buf)
  endif

  " Go back to the source buffer and do the initial compile.
  call s:CocoCompileRestorePos()

  if s:coco_compile_watch
    call s:CocoCompileWatchUpdate()

    augroup CocoCompileAuWatch
      autocmd InsertLeave <buffer> call s:CocoCompileWatchUpdate()
    augroup END
  else
    call s:CocoCompileUpdate(a:startline, a:endline)
  endif
endfunction

" Complete arguments for the CocoCompile command.
function! s:CocoCompileComplete(arg, cmdline, cursor)
  let args = ['unwatch', 'vertical', 'watch']

  if !len(a:arg)
    return args
  endif

  let match = '^' . a:arg

  for arg in args
    if arg =~ match
      return [arg]
    endif
  endfor
endfunction

" Don't let new windows overwrite the CocoCompile variables.
if !exists("s:coco_compile_buf")
  call s:CocoCompileResetVars()
endif

" Peek at compiled Coco.
command! -range=% -bar -nargs=* -complete=customlist,s:CocoCompileComplete
\        CocoCompile call s:CocoCompile(<line1>, <line2>, <q-args>)
" Run some Coco.
command! -range=% -bar CocoRun <line1>,<line2>:w !coco -seb

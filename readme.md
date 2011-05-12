### Installing and Using

1. Install [tpope's][tpope] [pathogen] into `~/.vim/autoload/` and add the
   following line to your `~/.vimrc`:

        call pathogen#runtime_append_all_bundles()

     Be aware that it must be added before any `filetype plugin indent on`
     lines according to the install page:

     > Note that you need to invoke the pathogen functions before invoking
     > "filetype plugin indent on" if you want it to load ftdetect files. On
     > Debian (and probably other distros), the system vimrc does this early on,
     > so you actually need to "filetype off" before "filetype plugin indent on"
     > to force reloading.

[pathogen]: http://www.vim.org/scripts/script.php?script_id=2332
[tpope]: http://github.com/tpope/vim-pathogen

2. Create, and change into, the `~/.vim/bundle/` directory:

        $ mkdir -p ~/.vim/bundle
        $ cd ~/.vim/bundle

3. Make a clone of the `vim-coco` repository:

        $ git clone git://github.com/satyr/vim-coco.git
        [...]
        $ ls
        vim-coco/

That's it. Pathogen should handle the rest. Opening a file with a `.co`
extension or a `Cokefile` will load everything.

### Updating

1. Change into the `~/.vim/bundle/vim-coco/` directory:

        $ cd ~/.vim/bundle/vim-coco

2. Pull in the latest changes:

        $ git pull

Everything will then be brought up to date.

### Compiling the Current File and Autocompiling

The `CocoMake` command compiles the current file and parses any errors.

By default, `CocoMake` shows all compiler output and jumps to the line
reported as an error by `coco`:

    :CocoMake

Compiler output can be hidden with `silent`:

    :silent CocoMake

Line-jumping can be turned off by adding a bang:

    :CocoMake!

Options given to `CocoMake` are passed along to `coco`:

    :CocoMake --bare

The command can be bound to a key like:

    nmap KEY :CocoMake<CR>

#### Autocompiling

To get autocompiling when a file is written,
add an `autocmd` like this to your `~/.vimrc`:

    autocmd BufWritePost *.co silent CocoMake!

All of the customizations above can be used, too. This one compiles silently
with the `-b` option, but shows any errors:

    autocmd BufWritePost *.co silent CocoMake! -b | cwindow

#### Passing options on-the-fly

The `CocoMake` command passes any options in the `coco_make_options`
variable along to the compiler. This can be used to set options on-the-fly:

    :let coco_make_options = "-n"

### Compiling a Coco Snippet

The `CocoCompile` command shows how the current file or a snippet of
Coco would be compiled to JavaScript. Calling `CocoCompile` without a
range compiles the entire file.

Calling `CocoCompile` with a range, like in visual mode, compiles the selected
snippet of Coco.

The command can also be mapped to a visual mode key for convenience:

    vmap KEY :CocoCompile<CR>

### Customizing

These customizations can be enabled or disabled by adding the relevant `let`
statement to your `~/.vimrc`.

#### Fold by indentation

Folding is automatically setup as indent-based.
It's disabled by default, but can be enabled with:

    let coco_folding = 1

Otherwise, it can be quickly toggled per-file with the `zi` command.

#### Disable trailing whitespace error

Trailing whitespace is highlighted as an error by default. This can be disabled
with:

    let coco_no_trailing_space_error = 1

#### Disable trailing semicolon error

Trailing semicolons are also considered an error. This can be disabled with:

    let coco_no_trailing_semicolon_error = 1

#### Disable reserved words error

Reserved words such as `var` and `static` are highlighted as error in contexts
disallowed by Coco. This can be disabled with:

    let coco_no_reserved_words_error = 1

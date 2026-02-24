" put this line first in ~/.vimrc
set nocompatible | filetype indent plugin on | syn on

fun! SetupVAM()
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME', 1) . '/.vim/vim-addons'

  " Force your ~/.vim/after directory to be last in &rtp always:
  " let g:vim_addon_manager.rtp_list_hook = 'vam#ForceUsersAfterDirectoriesToBeLast'

  " most used options you may want to use:
  " let c.log_to_buf = 1
  " let c.auto_install = 0
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  if !isdirectory(c.plugin_root_dir.'/vim-addon-manager/autoload')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '
        \       shellescape(c.plugin_root_dir.'/vim-addon-manager', 1)
  endif

  " This provides the VAMActivate command, you could be passing plugin names, too
  call vam#ActivateAddons([], {})
endfun

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'Valloric/YouCompleteMe'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'sniphpets/sniphpets'
Bundle 'wdalmut/vim-phpunit.git'
Bundle 'vim-php/vim-composer'
Plugin 'scrooloose/nerdtree'
""Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'jwalton512/vim-blade'
"Plugin 'tpope/vim-rails'
" Track the engine.
Plugin 'SirVer/ultisnips'
Plugin 'airblade/vim-gitgutter'
" " Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'
Plugin 'MarcWeber/vim-addon-manager'
Plugin 'thoughtbot/vim-rspec'
Bundle 'ervandew/supertab'
Plugin 'rails.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'majutsushi/tagbar'
Plugin 'dracula/vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
" " Trigger configuration. Do not use <tab> if you use
Bundle 'scrooloose/syntastic'
Plugin 'wikitopian/hardmode'
Plugin 'flazz/vim-colorschemes'
Plugin 'gregsexton/MatchTag'
Plugin 'nathanaelkane/vim-indent-guides'
" https://github.com/Valloric/YouCompleteMe.
"
" " If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"Plugin manger settings VAM"
":"set nocompatible | filetype indent plugin on | syn on
""set runtimepath+=/path/to/vam
""call vam#ActivateAddons([PLUGIN_NAME])
" Track the engine
syntax enable
"set smartindent
"set tabstop=4
"set shiftwidth=4
"set expandtab
"set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set backupcopy=yes
colorscheme dracula 
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
retab
set nu
"Auto remove trailing spaces"
""autocmd BufWritePre *.php %s/\s\+$//e
""set rnu
ino " ""<left>
ino ' ''<left>
ino ( ()<left>
ino [ []<left>
ino { {}<left>
ino {<CR> {<CR>}<ESC>O
"Better leader"
set showcmd
let mapleader = " "
""set mouse=a;
" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:ycm_key_invoke_completion = '<C-ALT>'
let g:UltiSnipsJumpForwardTrigger = "<Right>"
let g:UltiSnipsJumpBackwardTrigger = "<Left>"
let g:UltiSnipsExpandTrigger="<c-j>"
let g:SuperTabDefaultCompletionType = '<C-n>'


""let g:UltiSnipsExpandTrigger="<ALT>"
""let g:UltiSnipsJumpForwardTrigger="<c-b>"
""let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<C-CR>"
let g:UltiSnipsJumpForwardTrigger = "<C-tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline))"""''
let g:phpqa_codesniffer_args = "--standard=PSR2"
"let g:ycm_server_python_interpreter = '/usr/bin/python'

"Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_w = 1
let g:syntastic_check_on_wq = 0

"Ctrl-p customs"
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](doc|tmp|node_modules)',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_clear_cache_on_exit = 0
if executable('ag')
    let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore .DS_Store
      \ --ignore "**/*.pyc"
      \ -g ""'
endif

"Airline
let g:airline_section_y = 'BN: %{bufnr("%")}'
"Tagbar trigger"
nmap <F8> :TagbarToggle<CR>
"Delete line "
nnoremap <leader>d dd
"Delete line and set write mode"
nnoremap <leader>c ddO
"Semicolon at line end for PHP"
nnoremap <leader>, $a;<ESC>
"Delete current word and set insert mode"
nnoremap <leader>i <ESC>vexi
"Delete all trailing spaces in line"

"Start Hard/Easy mode
nnoremap <C-h> :call HardMode()
"Change window"
nnoremap <leader><Left> <ESC><C-w><Left>
nnoremap <leader><Up> <ESC><C-w><Up>
nnoremap <leader><Down> <ESC><C-w><Down>
nnoremap <leader><Right> <ESC><C-w><Right>
"
"Better NERDTree"
nnoremap <leader>v :NERDTreeFind<CR>
let NERDTreeQuitOnOpen = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
nnoremap <leader>n :NERDTreeToggle<CR>
au BufWinLeave ?* mkview
au BufWinEnter ?* silent loadview

function! g:UltiSnips_Complete()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            return "\<C-n>"
        else
            call UltiSnips#JumpForwards()
            if g:ulti_jump_forwards_res == 0
               return "\<TAB>"
            endif
        endif
    endif
    return ""
endfunction

au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-e>"
" this mapping Enter key to <C-y> to chose the current highlight item 
" and close the selection list, same as other IDEs.
" CONFLICT with some plugins like tpope/Endwise
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

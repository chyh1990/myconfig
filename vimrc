set nocompatible
" source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

" Chenyh's setting
" for Linux

syntax on    
set number   
" set cmdheight=2
colo darkblue  
set autoindent
set smartindent
set nocompatible 
set autochdir
set smarttab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set nocp
filetype plugin on


" set tags+=$VIMRUNTIME/../vimfiles/tags/sdltags
" set tags+=$VIMRUNTIME/../vimfiles/tags/boosttags
set tags+=$VIMRUNTIME/../vimfiles/tags/stltags
set tags+=./tags,../tags,../../tags,../../../tags
set tags+=$VIMRUNTIME/../vimfiles/tags/systags

let Tlist_File_Fold_Auto_Close=1
let Tlist_Ctags_Cmd='/Users/chenyh/prog/bin/bin/ctags'


noremap <c-down> <c-w>j
noremap <c-up> <c-w>k
noremap <c-left> <c-w>h
noremap <c-right> <c-w>l

noremap <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --if0=yes . <CR>

let OmniCpp_DefaultNamespaces = ["std"]
let OmniCpp_GlobalScopeSearch = 1  " 0 or 1
let OmniCpp_NamespaceSearch = 1   " 0 ,  1 or 2
let OmniCpp_DisplayMode = 0
let OmniCpp_ShowScopeInAbbr = 1
let OmniCpp_ShowPrototypeInAbbr = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_MayCompleteDot = 1
let OmniCpp_MayCompleteArrow = 1
let OmniCpp_MayCompleteScope = 1
au FileType python set omnifunc=pythoncomplete#Complete
let g:SuperTabDefaultCompletionType = "context"

autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
set completeopt=menu


set foldenable
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

" map <esc>
imap jk <Esc>
set timeoutlen=500


nnoremap <C-N> :tabnew<space>

let g:winManagerWindowLayout = "TagList|FileExplorer,BufExplorer"
let g:winManagerWidth = 30
 
nmap <silent> <F3> :WMToggle<cr>
let g:AutoOpenWinManager = 1

if has("win32") 
set guifont=Consolas:h11 
endif 

" autocmd FileType python set omnifunc=pythoncomplete#Complete

" Latex
let g:Tex_DefaultTargetFormat='pdf'

" let g:fencview_autodetect = 1

nnoremap <C-P> :tabp<CR>


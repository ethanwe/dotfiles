set clipboard=unnamedplus

set relativenumber
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set nowrap
set smartcase
set ignorecase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set scrolloff=8
set signcolumn=yes
set colorcolumn=140
set termguicolors

inoremap jj <Esc>
let mapleader = ","

" Reset highlighted search
"nnoremap <CR> :let @/=""<CR><CR>
"clear search on timer
function! SearchHlClear()
    let @/ = ''
endfunction
augroup searchhighlight
    autocmd!
    autocmd CursorHold,CursorHoldI * call SearchHlClear()
augroup END

call plug#begin('~/.vim/plugged')

" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html', 'yml'] }

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim' 
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
"Plug 'karb94/neoscroll.nvim'
Plug 'hoob3rt/lualine.nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'morhetz/gruvbox'

call plug#end()
colorscheme gruvbox

"TELESCOPE: SHOULD REFACTOR
lua << EOF
require('telescope').setup {
	defaults = {
		prompt_prefix = "> "
	},
	extensions = {
		fzf = {
			fuzzy = true,                    -- false will only do exact matching
			override_generic_sorter = false, -- override the generic sorter
			override_file_sorter = true,     -- override the file sorter
			case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
		}
	}
}
require('telescope').load_extension('fzf')




--lsp config
require'lspconfig'.tsserver.setup{}

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>.', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<space>p', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', '<space>n', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pyright", "rust_analyzer", "tsserver" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- Compe setup
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    nvim_lsp = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})



--lualina
require('lualine').setup({
	options = {
		icons_enabled = true,
		theme = 'gruvbox',
		component_separators = {'', ''},
		section_separators = {'', ''},
		disabled_filetypes = {}
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch'},
		lualine_c = {'filename', {'diagnostics', sources = {'nvim_lsp'}}, {'diff'}},
		lualine_x = {'location'},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {
	  --lualine_b = {'branch'},
	  --lualine_c = {'filename'},
		--lualine_x = { {'diagnostics', sources = {'nvim_lsp'}}},
	},
	extensions = {'fugitive'}
})
EOF

set completeopt=menuone,noselect
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })


"scroll
"lua require('neoscroll').setup()

" fuzzy
nnoremap <C-P> :Telescope find_files<cr>
nnoremap <C-f> :Telescope live_grep<cr>
nnoremap <leader>fg :Telescope git_files<cr>
nnoremap <leader>fc :Telescope git_commits<cr>
nnoremap <leader>fs :Telescope grep_string search
nnoremap <leader>fq :Telescope quickfix<cr>
nnoremap <leader>ws :Telescope file_browser<cr>
nnoremap - :Telescope file_browser<cr>

let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

"airline
let g:airline_statusline_ontop=1
let g:airline#extensions#tabline#enabled = 1

" git
nnoremap <leader>gd :Gdiffsplit<cr>
nnoremap <leader>gg :G<cr>

nnoremap <leader>ev :e ~/.config/nvim/init.vim<cr>
nnoremap <leader>sv :source ~/.config/nvim/init.vim<cr>
nnoremap <leader>eb :e ~/.bashrc<cr>
nnoremap <leader>eg :e ~/.gitconfig<cr>

" movement
nnoremap <Esc>j }
nnoremap <Esc>k {

nnoremap <C-h> :bp<CR>
nnoremap <C-l> :bn<CR>

" windows

nmap <leader>h :wincmd h<CR>
nmap <leader>j :wincmd j<CR>
nmap <leader>k :wincmd k<CR>
nmap <leader>l :wincmd l<CR>

nnoremap <leader>d :saveas<space><C-r>%

nnoremap <C-s> :w <cr>
nnoremap <C-w> :q<cr>

"quickfix list
nnoremap <C-j> :cn<cr>
nnoremap <C-k> :cp<cr>
nnoremap <space>j :lnext<cr>
nnoremap <space>k :lprev<cr>
nnoremap <leader>q :cclose<cr>:lcl<cr>

"nnoremap <leader>d :saveas<space><C-r>%

"file stuff
function! SaveAs()
	let duplicateFileName = input('Enter filename for duplicate file: ')
	execute "saveas " duplicateFileName
endfunction
"nnoremap <leader>da :call SaveAs()<CR>
nnoremap <leader>da :saveas<space><C-r>%
nnoremap <leader>dm :Move<space><C-r>%
nnoremap <leader>dq :Delete<CR>
nnoremap <leader>dd :Mkdir<space>


" 
" function InsertIfEmpty()
"    if @% == ""
"        " No filename for current buffer
"		execute "Telescope file_browser<cr>"
"    elseif filereadable(@%) == 0
"        " File doesn't exist yet
"        startinsert
"    elseif line('$') == 1 && col('$') == 1
"        " File is empty
"        startinsert
"    endif
"endfunction

"au VimEnter * call InsertIfEmpty()

-- set leader key to space
vim.g.mapleader = " "

local km = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- use jk/kj to exit insert mode
-- km.set("i", "jk", "<ESC>")
-- km.set("i", "kj", "<ESC>")

-- clear search highlights
km.set("n", "<C-n>", ":nohl<CR>", { silent = true })
km.set("v", "<C-n>", ":nohl<CR>", { silent = true })
km.set("i", "<C-n>", ":nohl<CR>", { silent = true })

-- delete single character without copying into register
km.set("n", "x", '"_x')

km.set("n", "<Tab>", ":bnext<CR>", { silent = true })
km.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true })

-- " Quickfix Shortcuts
-- map <C-j> :cn<CR>
-- map <C-k> :cp<CR>

-- " Use <leader>qq in normal mode to quit all
km.set("n", "<leader>qa", ":qa<CR>", { silent = true })
-- " Use qq in normal mode to close current buffer
-- km.set("n", "qq", ":bp <BAR> bd #<CR>", { silent = true })

km.set("n", "<leader>c", '"_c')

-- write without formatting
km.set("n", "<leader>w", ":noa w<CR>", { silent = true })
km.set("i", "<leader>w", "<ESC>:noa w<CR>", { silent = true })

km.set("n", "<leader>bb", "Oif err != nil {\nreturn err\n}<C-c>")
km.set("n", "<leader>bn", "Oif err != nil {\nreturn nil, err\n}<C-c>")

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
km.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
km.set("n", "<leader>;", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope
km.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
km.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
km.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
km.set("n", "<leader>l", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
km.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- temp
km.set("n", "<leader>s.", "<cmd>Telescope oldfiles<cr>")
km.set("n", "<leader>sr", "<cmd>Telescope resume<cr>")

local builtin = require("telescope.builtin")
km.set("n", "<leader>fr", builtin.lsp_references)
km.set("n", "<leader>fi", "<cmd>Telescope lsp_incoming_calls<cr>")
km.set("n", "<leader>fo", "<cmd>Telescope lsp_outgoing_calls<cr>")
km.set("n", "<C-h>", builtin.jumplist) -- list jumplist entries
km.set("n", "<C-p>", builtin.git_files) -- list available help tags

-- telescope git commands (not on youtube nvim video)
km.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
km.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
km.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
km.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
km.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- quickfix
km.set("n", "<C-j>", ":cn<CR>zz")
km.set("n", "<C-k>", ":cp<CR>zz")

-- sort
km.set("v", "<leader>s", ":sort<CR>")

km.set("n", "<leader><Right>", "<Cmd>Lspsaga goto_definition<CR>")
km.set("n", "<leader><Left>", "<C-o>")

km.set("n", "<leader>gt", "<cmd>! cd %:h; go test .<CR>")

-- copy current file name and line number to clipboard
km.set("n", "<leader>b", "<cmd>let @+ = 'b ' . join([expand('%'),  line('.')], ':')<CR>") -- copy current file name and line number to clipboard
km.set("n", "<leader>y", "<cmd>let @+ = expand('%:p')<CR><cmd>echo expand('%:p')<CR>") -- copy current file name to clipboard

-- gitlinker
km.set(
    "n",
    "<leader>gb",
    '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
    { silent = true }
)
km.set("n", "<leader>gY", '<cmd>lua require"gitlinker".get_repo_url()<cr>', { silent = true })
km.set(
    "n",
    "<leader>gB",
    '<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>',
    { silent = true }
)

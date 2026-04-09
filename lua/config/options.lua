-- 기본 옵션 설정
local opt = vim.opt

-- 줄 번호
opt.number = true
opt.relativenumber = false

-- 들여쓰기
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- 검색
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.showmode = false
opt.splitbelow = true
opt.splitright = true

-- 파일
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- 성능
opt.updatetime = 250
opt.timeoutlen = 300

-- 클립보드 (시스템 클립보드 공유)
opt.clipboard = "unnamedplus"

-- 자동완성 메뉴
opt.completeopt = { "menu", "menuone", "noselect" }

-- Leader 키 설정
vim.g.mapleader = " "
vim.g.maplocalleader = " "

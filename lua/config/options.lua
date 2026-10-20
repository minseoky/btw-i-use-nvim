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

-- Python 괄호 안 들여쓰기를 black/ruff 스타일로 (기본값은 8칸 + 닫는 괄호도 8칸)
vim.g.python_indent = {
    open_paren = "shiftwidth()",
    continue = "shiftwidth()",
    closed_paren_align_last_line = false,
}

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

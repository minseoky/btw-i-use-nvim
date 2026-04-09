-- 자동 명령 설정
local autocmd = vim.api.nvim_create_autocmd

-- 파일 열 때 마지막 편집 위치로 이동
autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- 저장 시 trailing whitespace 제거
autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

-- 언어별 들여쓰기 설정
autocmd("FileType", {
    pattern = { "go" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = false -- Go는 탭 사용
    end,
})

autocmd("FileType", {
    pattern = { "yaml", "json", "lua", "javascript", "typescript" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- yank 시 하이라이트
autocmd("TextYankPost", {
    callback = function()
        local hl = vim.hl or vim.highlight
        hl.on_yank({ timeout = 200 })
    end,
})

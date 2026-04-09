-- lazy.nvim 부트스트랩 (자동 설치)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- plugins/ 디렉토리의 모든 플러그인 스펙을 자동 로드
require("lazy").setup("plugins", {
    checker = { enabled = true, notify = false },
    change_detection = { notify = false },
})

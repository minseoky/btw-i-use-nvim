-- 자동완성 설정 (IntelliJ의 코드 자동완성과 유사)
return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",     -- LSP 소스
            "hrsh7th/cmp-buffer",        -- 버퍼 내 단어
            "hrsh7th/cmp-path",          -- 파일 경로
            "L3MON4D3/LuaSnip",         -- 스니펫 엔진
            "saadparwaiz1/cmp_luasnip",  -- 스니펫 소스
            "rafamadriz/friendly-snippets", -- 미리 정의된 스니펫 모음
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            -- 미리 정의된 스니펫 로드
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),       -- 수동 트리거
                    ["<C-e>"] = cmp.mapping.abort(),              -- 취소
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter로 선택
                    -- Tab으로 항목 이동
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },  -- LSP (최우선)
                    { name = "luasnip",  priority = 750 },   -- 스니펫
                    { name = "buffer",   priority = 500 },   -- 버퍼 단어
                    { name = "path",     priority = 250 },   -- 파일 경로
                }),
                formatting = {
                    format = function(entry, vim_item)
                        local source_names = {
                            nvim_lsp = "[LSP]",
                            luasnip  = "[Snip]",
                            buffer   = "[Buf]",
                            path     = "[Path]",
                        }
                        vim_item.menu = source_names[entry.source.name] or ""
                        return vim_item
                    end,
                },
            })
        end,
    },
}

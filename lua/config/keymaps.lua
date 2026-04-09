-- 키맵 설정
local map = vim.keymap.set

-- 더 나은 창 이동 (Ctrl+hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "왼쪽 창으로 이동" })
map("n", "<C-j>", "<C-w>j", { desc = "아래쪽 창으로 이동" })
map("n", "<C-k>", "<C-w>k", { desc = "위쪽 창으로 이동" })
map("n", "<C-l>", "<C-w>l", { desc = "오른쪽 창으로 이동" })

-- 창 크기 조절
map("n", "<C-Up>", ":resize +2<CR>", { desc = "창 높이 증가" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "창 높이 감소" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "창 폭 감소" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "창 폭 증가" })

-- 버퍼 이동 (IntelliJ의 탭 이동과 유사)
map("n", "<S-l>", ":bnext<CR>", { desc = "다음 버퍼" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "이전 버퍼" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "버퍼 닫기" })

-- Visual 모드에서 블록 이동
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "선택 블록 아래로" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "선택 블록 위로" })

-- 검색 후 화면 중앙 유지
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- 검색 하이라이트 해제
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "검색 하이라이트 해제" })

-- 더 나은 붙여넣기 (덮어쓸 때 레지스터 유지)
map("x", "<leader>p", '"_dP', { desc = "레지스터 유지 붙여넣기" })

-- 전체 파일 저장
map("n", "<leader>w", ":w<CR>", { desc = "파일 저장" })
map("n", "<leader>q", ":q<CR>", { desc = "창 닫기" })

-- 터미널 모드에서 ESC로 나가기
map("t", "<Esc>", "<C-\\><C-n>", { desc = "터미널 Normal 모드" })

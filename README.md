# Neovim Configuration

Java, Go, Python 개발을 위한 IDE급 Neovim 설정.
IntelliJ/PyCharm 사용자가 전환하기 쉽도록 유사한 키맵과 기능을 제공한다.

## 한 줄 설치

```bash
git clone git@github.com:<username>/nvim-config.git ~/.config/nvim && ~/.config/nvim/install.sh
```

이것만 실행하면 아래 전체 과정이 자동으로 진행된다.

## 설치 과정 상세

`install.sh`는 OS를 자동 감지하여 macOS(brew), Ubuntu/Debian(apt), Fedora(dnf), Arch(pacman), Alpine(apk)에서 동작한다.
아래는 스크립트가 수행하는 전체 과정이다.

### 1. OS 감지

macOS / Linux를 자동 감지한다. 이후 단계에서 OS에 맞는 패키지 매니저를 사용한다.

### 2. Neovim 설치

| OS | 방법 |
|---|---|
| macOS | `brew install neovim` |
| Ubuntu/Debian | PPA (`neovim-ppa/unstable`) 추가 후 `apt install neovim` |
| Fedora | `dnf install neovim` |
| Arch | `pacman -S neovim` |
| Alpine | `apk add neovim` |
| 기타 Linux | AppImage fallback |

### 3. 필수 도구 설치

이미 설치된 도구는 건너뛴다.

| 도구 | 용도 |
|---|---|
| ripgrep (`rg`) | Telescope 텍스트 검색 |
| fd | Telescope 파일 검색 |
| git | 플러그인 관리, gitsigns |
| Node.js | 일부 LSP 서버 |
| Bash 4+ (macOS만) | SDKMAN 요구사항 (macOS 기본 bash는 3.x) |

### 4. SDKMAN + Java 설치

[SDKMAN](https://sdkman.io)은 Java 버전 관리 도구다. 스크립트가 자동으로 설치한 뒤 두 개의 Java 버전을 설치한다.

| 버전 | 배포판 | 용도 |
|---|---|---|
| Java 21 (Temurin) | `21.0.10-tem` | 기본값, jdtls(Java LSP) 실행용 |
| Java 8 (Zulu) | `8.0.482-zulu` | 레거시 프로젝트용 |

설치 후 `JAVA_HOME`은 Java 21로 설정된다. 쉘에서 버전 전환:

```bash
sdk use java 8.0.482-zulu     # 현재 쉘에서만 Java 8로 전환
sdk use java 21.0.10-tem      # 다시 21로 복귀
sdk default java 8.0.482-zulu # 모든 새 쉘의 기본값 변경
```

프로젝트별 자동 전환은 프로젝트 루트에 `.sdkmanrc` 생성:

```bash
echo "java=8.0.482-zulu" > .sdkmanrc
```

### 5. Nerd Font 설치

아이콘 표시를 위해 **JetBrainsMono Nerd Font**를 설치한다.

| OS | 방법 |
|---|---|
| macOS | `brew install --cask font-jetbrains-mono-nerd-font` |
| Linux | GitHub Releases에서 다운로드 후 `~/.local/share/fonts`에 설치 |

> 설치 후 **터미널 앱의 폰트를 JetBrainsMono Nerd Font로 변경**해야 아이콘이 정상 표시된다.
>
> - **iTerm2**: Preferences → Profiles → Text → Font
> - **macOS Terminal**: 설정 → 프로파일 → 서체
> - **GNOME Terminal**: 기본 설정 → 프로파일 → 사용자 지정 글꼴
> - **Windows Terminal**: settings.json → `"fontFace": "JetBrainsMono Nerd Font"`

### 6. 설정 파일 배치

저장소를 `~/.config/nvim`에 직접 클론한 경우 그대로 사용한다.
다른 경로에 클론한 경우 `~/.config/nvim`으로 심볼릭 링크를 생성한다.
기존 nvim 설정이 있으면 `.backup.{timestamp}` 이름으로 백업한다.

### 7. 플러그인 설치 (lazy.nvim)

Neovim을 headless 모드로 실행하여 lazy.nvim이 모든 플러그인을 자동 다운로드한다.

설치되는 주요 플러그인:

| 플러그인 | 역할 |
|---|---|
| tokyonight.nvim | 컬러스킴 |
| lualine.nvim | 하단 상태바 |
| bufferline.nvim | 상단 버퍼 탭 |
| neo-tree.nvim | 파일 탐색기 (← `Space e`) |
| telescope.nvim | 퍼지 파일/텍스트 검색 |
| nvim-treesitter | 구문 강조, 코드 선택 |
| nvim-cmp + LuaSnip | 자동완성 + 스니펫 |
| mason.nvim | LSP/포매터/린터 설치 관리 |
| gitsigns.nvim | Git 변경 표시 |
| toggleterm.nvim | 내장 터미널 |
| which-key.nvim | 키맵 도우미 |
| Comment.nvim | 주석 토글 |
| nvim-surround | 괄호/따옴표 조작 |
| nvim-autopairs | 자동 괄호 닫기 |
| conform.nvim | 저장 시 자동 포맷팅 |

### 8. LSP 서버 설치 (Mason)

Mason이 다음 LSP 서버를 자동 설치한다:

| 서버 | 언어 |
|---|---|
| gopls | Go |
| pyright | Python |
| jdtls | Java |
| lua_ls | Lua (Neovim 설정 편집용) |

### 9. 첫 실행

```bash
nvim
```

- Treesitter 파서가 자동 설치된다 (1~2분 소요)
- `:Mason`으로 LSP 서버 설치 상태 확인
- 포매터 추가 설치: `:MasonInstall gofumpt goimports black stylua prettier`

### 수동 설치 (install.sh 없이)

스크립트 없이 직접 설치하려면:

```bash
# 1. Neovim 설치
brew install neovim              # macOS
# sudo apt install neovim        # Ubuntu

# 2. 필수 도구
brew install ripgrep fd node bash

# 3. SDKMAN + Java
curl -s "https://get.sdkman.io" | /opt/homebrew/bin/bash  # macOS (bash 4+ 필요)
# curl -s "https://get.sdkman.io" | bash                   # Linux
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.10-tem
sdk install java 8.0.482-zulu

# 4. Nerd Font
brew install --cask font-jetbrains-mono-nerd-font  # macOS
# Linux: https://github.com/ryanoasis/nerd-fonts/releases 에서 다운로드

# 5. 설정 클론
git clone git@github.com:<username>/nvim-config.git ~/.config/nvim

# 6. Neovim 실행 (플러그인 자동 설치됨)
nvim

# 7. Neovim 안에서 LSP 서버 설치
# :MasonInstall gopls pyright jdtls lua-language-server
# :MasonInstall gofumpt goimports black stylua prettier
```

## 디렉토리 구조

```
~/.config/nvim/
├── init.lua                 # 진입점
├── install.sh               # 포터블 설치 스크립트
├── lua/
│   ├── config/
│   │   ├── options.lua      # 기본 옵션 (줄번호, 들여쓰기, 클립보드 등)
│   │   ├── keymaps.lua      # 키맵 (Leader = Space)
│   │   ├── autocmds.lua     # 자동 명령 (언어별 들여쓰기, trailing whitespace 등)
│   │   └── lazy.lua         # lazy.nvim 부트스트랩
│   └── plugins/
│       ├── colorscheme.lua  # tokyonight 테마
│       ├── ui.lua           # 상태바, 버퍼탭, which-key, 알림
│       ├── editor.lua       # 파일탐색기, Telescope, Treesitter, Git, 터미널
│       ├── lsp.lua          # LSP (Go/Python/Java) + Mason + conform
│       └── cmp.lua          # 자동완성 (nvim-cmp + LuaSnip)
```


## Vim 기초 (모드 시스템)

Vim은 모드 기반 에디터다. 현재 모드는 좌측 하단에 표시된다.

| 모드 | 진입 | 용도 |
|---|---|---|
| **Normal** | `Esc` | 탐색, 명령 실행 (기본 모드) |
| **Insert** | `i`, `a`, `o` | 텍스트 입력 |
| **Visual** | `v`, `V`, `Ctrl+v` | 텍스트 선택 |
| **Command** | `:` | Ex 명령 실행 |
| **Terminal** | `Ctrl+\` | 내장 터미널 |

### 기본 이동 (Normal 모드)

| 키 | 동작 |
|---|---|
| `h` `j` `k` `l` | 좌 하 상 우 (화살표 대신 사용) |
| `w` / `b` | 다음 / 이전 단어 |
| `0` / `$` | 줄 처음 / 끝 |
| `gg` / `G` | 파일 처음 / 끝 |
| `Ctrl+d` / `Ctrl+u` | 반 페이지 아래 / 위 |
| `%` | 짝 괄호로 이동 |
| `{` / `}` | 이전 / 다음 빈 줄 |

### 기본 편집 (Normal 모드)

| 키 | 동작 |
|---|---|
| `i` / `a` | 커서 앞 / 뒤에서 입력 시작 |
| `I` / `A` | 줄 처음 / 끝에서 입력 시작 |
| `o` / `O` | 아래 / 위에 새 줄 추가 후 입력 |
| `dd` | 줄 삭제 (잘라내기) |
| `yy` | 줄 복사 |
| `p` / `P` | 커서 뒤 / 앞에 붙여넣기 |
| `u` / `Ctrl+r` | 실행 취소 / 다시 실행 |
| `x` | 문자 삭제 |
| `ciw` | 단어 변경 (change inner word) |
| `di"` | 따옴표 안 내용 삭제 |
| `.` | 마지막 동작 반복 |

### 검색

| 키 | 동작 |
|---|---|
| `/패턴` | 아래로 검색 |
| `?패턴` | 위로 검색 |
| `n` / `N` | 다음 / 이전 결과 |
| `*` / `#` | 커서 아래 단어를 아래/위로 검색 |

## 커스텀 키맵

> Leader 키는 `Space`이다. 아래에서 `Space`로 시작하는 조합은 Normal 모드에서 Space를 누른 뒤 이어서 입력한다.
> `Space`를 누르고 잠시 기다리면 which-key가 사용 가능한 키 목록을 보여준다.

### 파일 & 검색 (Telescope)

| 키 | 동작 | IntelliJ 대응 |
|---|---|---|
| `Space` `f` `f` | 파일 이름으로 찾기 | `Ctrl+Shift+N` |
| `Space` `f` `g` | 전체 텍스트 검색 (grep) | `Ctrl+Shift+F` |
| `Space` `f` `b` | 열린 버퍼 목록 | - |
| `Space` `f` `r` | 최근 파일 | `Ctrl+E` |
| `Space` `f` `s` | 현재 파일 심볼 검색 | `Ctrl+F12` |
| `Space` `f` `d` | 진단(에러/경고) 목록 | - |

### 파일 탐색기 (Neo-tree)

| 키 | 동작 | IntelliJ 대응 |
|---|---|---|
| `Space` `e` | 파일 탐색기 토글 | `Alt+1` |

Neo-tree 내부에서:

| 키 | 동작 |
|---|---|
| `Enter` | 파일 열기 / 디렉토리 펼침 |
| `a` | 새 파일/디렉토리 생성 |
| `d` | 삭제 |
| `r` | 이름 변경 |
| `c` / `m` / `p` | 복사 / 이동 / 붙여넣기 |
| `H` | 숨김 파일 토글 |
| `R` | 새로고침 |

### 코드 네비게이션 (LSP)

| 키 | 동작 | IntelliJ 대응 |
|---|---|---|
| `gd` | 정의로 이동 | `Ctrl+B` |
| `gD` | 선언으로 이동 | `Ctrl+B` |
| `gr` | 참조(사용처) 찾기 | `Alt+F7` |
| `gi` | 구현으로 이동 | `Ctrl+Alt+B` |
| `gt` | 타입 정의로 이동 | `Ctrl+Shift+B` |
| `K` | 문서 보기 (hover) | `Ctrl+Q` |

### 리팩토링 & 코드 액션 (LSP)

| 키 | 동작 | IntelliJ 대응 |
|---|---|---|
| `Space` `l` `r` | 이름 변경 (Rename) | `Shift+F6` |
| `Space` `l` `a` | 코드 액션 (Quick Fix) | `Alt+Enter` |
| `Space` `l` `f` | 코드 포맷팅 | `Ctrl+Alt+L` |
| `Space` `l` `s` | 시그니처 도움말 | `Ctrl+P` |

### 진단 (Diagnostics)

| 키 | 동작 |
|---|---|
| `Space` `x` `d` | 현재 줄 진단 상세 보기 |
| `Space` `x` `l` | 진단 목록 (loclist) |
| `]d` / `[d` | 다음 / 이전 진단으로 이동 |

### 창 관리

| 키 | 동작 |
|---|---|
| `Ctrl+h/j/k/l` | 왼쪽/아래/위/오른쪽 창으로 이동 |
| `Ctrl+방향키` | 창 크기 조절 |
| `:vs` | 수직 분할 |
| `:sp` | 수평 분할 |

### 버퍼 (탭)

| 키 | 동작 | IntelliJ 대응 |
|---|---|---|
| `Shift+L` | 다음 버퍼 | `Ctrl+Tab` |
| `Shift+H` | 이전 버퍼 | `Ctrl+Shift+Tab` |
| `Space` `b` `d` | 버퍼 닫기 | `Ctrl+W` |

### Git

| 키 | 동작 |
|---|---|
| `]c` / `[c` | 다음 / 이전 Git 변경 |
| `Space` `g` `p` | 변경 내용 미리보기 |
| `Space` `g` `b` | Git Blame (줄 단위) |
| `Space` `g` `r` | 변경 되돌리기 (reset hunk) |

### 터미널

| 키 | 동작 | IntelliJ 대응 |
|---|---|---|
| `Ctrl+\` | 하단 터미널 토글 | `Alt+4` |
| `Space` `t` `f` | 플로팅 터미널 | - |
| `Esc` | 터미널에서 Normal 모드로 복귀 | - |

### 편집 보조

| 키 | 동작 |
|---|---|
| `gcc` | 현재 줄 주석 토글 |
| `gc` (Visual) | 선택 영역 주석 토글 |
| `J` / `K` (Visual) | 선택 블록 아래/위로 이동 |
| `ys{motion}{char}` | 감싸기 (예: `ysiw"` → 단어를 `"`로 감싸기) |
| `cs{old}{new}` | 감싸기 변경 (예: `cs"'` → `"` → `'`) |
| `ds{char}` | 감싸기 제거 (예: `ds"` → `"` 제거) |
| `Ctrl+Space` | 선택 영역 확장 (Treesitter) |
| `Backspace` | 선택 영역 축소 (Treesitter) |

### 기타

| 키 | 동작 |
|---|---|
| `Space` `w` | 파일 저장 |
| `Space` `q` | 창 닫기 |
| `Space` `h` | 검색 하이라이트 해제 |
| `Space` `p` (Visual) | 레지스터 유지 붙여넣기 |

## 자동완성

Insert 모드에서 타이핑하면 자동으로 완성 메뉴가 나타난다.

| 키 | 동작 |
|---|---|
| `Tab` / `Shift+Tab` | 다음 / 이전 항목 |
| `Enter` | 선택 확정 |
| `Ctrl+Space` | 수동으로 완성 메뉴 열기 |
| `Ctrl+e` | 완성 메뉴 닫기 |
| `Ctrl+b` / `Ctrl+f` | 문서 스크롤 |

소스 우선순위: `[LSP]` > `[Snip]` (스니펫) > `[Buf]` (버퍼 단어) > `[Path]` (파일 경로)

## 유용한 Ex 명령

| 명령 | 동작 |
|---|---|
| `:Mason` | LSP/포매터/린터 관리 UI |
| `:Lazy` | 플러그인 관리 UI |
| `:LspInfo` | 현재 LSP 서버 상태 |
| `:checkhealth` | Neovim 환경 진단 |
| `:TSInstall {lang}` | Treesitter 파서 추가 설치 |
| `:e {path}` | 파일 열기 |
| `:w` / `:q` / `:wq` | 저장 / 닫기 / 저장 후 닫기 |
| `:%s/old/new/g` | 전체 치환 |


## 저장 시 자동 동작

- trailing whitespace 자동 제거
- 코드 자동 포맷팅 (conform.nvim, 저장 시 실행)
- Go: `gofumpt` + `goimports`
- Python: `black`
- Java: `google-java-format`

## 언어별 들여쓰기

| 언어 | 탭 크기 | 탭 문자 |
|---|---|---|
| Go | 4 | 탭 (`\t`) |
| Java, Python | 4 | 스페이스 |
| YAML, JSON, Lua, JS/TS | 2 | 스페이스 |

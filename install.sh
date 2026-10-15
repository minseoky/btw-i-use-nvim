#!/usr/bin/env bash
# `sh install.sh`처럼 dash 등으로 실행되면 bash로 다시 실행 (pipefail, 배열 등 bash 문법 사용)
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi
set -euo pipefail

# ─── Neovim 환경 포터블 설치 스크립트 ───
# 사용법: git clone <repo> ~/.config/nvim && ~/.config/nvim/install.sh

NVIM_CONFIG_DIR="${HOME}/.config/nvim"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[1;32m[OK]\033[0m    %s\n" "$1"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$1"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$1"; exit 1; }

# root면 sudo 불필요, 아니면 sudo 사용
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# ─── 1. OS 감지 ───
detect_os() {
    case "$(uname -s)" in
        Linux*)  OS="linux" ;;
        Darwin*) OS="macos" ;;
        *)       error "지원하지 않는 OS: $(uname -s)" ;;
    esac
    info "감지된 OS: ${OS}"
}

# ─── 2. Neovim 설치 ───
NVIM_MIN_MINOR=11  # vim.lsp.config / vim.lsp.enable 필요

nvim_version_ok() {
    command -v nvim &>/dev/null || return 1
    local minor
    minor=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f2)
    [ "${minor:-0}" -ge "${NVIM_MIN_MINOR}" ]
}

install_nvim_appimage() {
    local arch
    case "$(uname -m)" in
        x86_64)        arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)             error "AppImage를 지원하지 않는 아키텍처: $(uname -m)" ;;
    esac
    info "Neovim AppImage (최신, ${arch}) 설치 중..."
    curl -fLo /tmp/nvim.appimage "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.appimage"
    chmod u+x /tmp/nvim.appimage
    ${SUDO} mv /tmp/nvim.appimage /usr/local/bin/nvim
}

install_neovim() {
    if nvim_version_ok; then
        ok "Neovim 이미 설치됨: $(nvim --version | head -1)"
        return
    fi

    info "Neovim 0.${NVIM_MIN_MINOR}+ 설치 중..."
    case "${OS}" in
        macos)
            if command -v brew &>/dev/null; then
                brew install neovim
            else
                error "Homebrew가 필요합니다. https://brew.sh 에서 설치하세요."
            fi
            ;;
        linux)
            # 먼저 패키지 매니저로 시도
            if command -v apt-get &>/dev/null; then
                ${SUDO} apt-get update
                if grep -qi ubuntu /etc/os-release 2>/dev/null; then
                    ${SUDO} apt-get install -y software-properties-common
                    ${SUDO} add-apt-repository -y ppa:neovim-ppa/unstable
                    ${SUDO} apt-get update
                fi
                ${SUDO} apt-get install -y neovim
            elif command -v dnf &>/dev/null; then
                ${SUDO} dnf install -y neovim
            elif command -v pacman &>/dev/null; then
                ${SUDO} pacman -S --noconfirm neovim
            elif command -v apk &>/dev/null; then
                ${SUDO} apk add neovim
            fi

            # 버전이 부족하면 AppImage로 덮어쓰기
            if ! nvim_version_ok; then
                warn "패키지 매니저의 Neovim이 0.${NVIM_MIN_MINOR} 미만입니다. AppImage로 재설치합니다."
                install_nvim_appimage
            fi
            ;;
    esac
    ok "Neovim 설치 완료: $(nvim --version | head -1)"
}

# ─── 3. 필수 도구 설치 ───
install_dependencies() {
    local deps=()

    command -v rg    &>/dev/null || deps+=("ripgrep")
    # Debian/Ubuntu의 fd-find 패키지는 실행 파일 이름이 fdfind
    command -v fd    &>/dev/null || command -v fdfind &>/dev/null || deps+=("fd")
    command -v git   &>/dev/null || deps+=("git")
    command -v node  &>/dev/null || deps+=("node")
    command -v unzip &>/dev/null || deps+=("unzip")
    command -v zip   &>/dev/null || deps+=("zip")
    command -v curl  &>/dev/null || deps+=("curl")
    command -v make  &>/dev/null || deps+=("make")
    command -v cc    &>/dev/null || deps+=("gcc")

    if [ ${#deps[@]} -eq 0 ]; then
        ok "모든 필수 도구가 이미 설치되어 있습니다."
    else
        info "필수 도구 설치: ${deps[*]}"
        case "${OS}" in
            macos)
                brew install "${deps[@]}"
                ;;
            linux)
                if command -v apt-get &>/dev/null; then
                    local apt_deps=()
                    for dep in "${deps[@]}"; do
                        case "${dep}" in
                            ripgrep) apt_deps+=("ripgrep") ;;
                            fd)      apt_deps+=("fd-find") ;;
                            node)    apt_deps+=("nodejs" "npm") ;;
                            *)       apt_deps+=("${dep}") ;;
                        esac
                    done
                    ${SUDO} apt-get install -y "${apt_deps[@]}"
                elif command -v dnf &>/dev/null; then
                    ${SUDO} dnf install -y "${deps[@]}"
                elif command -v pacman &>/dev/null; then
                    ${SUDO} pacman -S --noconfirm "${deps[@]}"
                fi
                ;;
        esac
        ok "필수 도구 설치 완료"
    fi

    # fdfind만 있으면 fd 이름으로 링크 (~/.local/bin은 PATH에 있어야 함)
    if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
        mkdir -p "${HOME}/.local/bin"
        ln -sf "$(command -v fdfind)" "${HOME}/.local/bin/fd"
        ok "fd 링크 생성: ${HOME}/.local/bin/fd -> $(command -v fdfind)"
    fi

    # Bash 4+ (SDKMAN 요구사항, macOS 기본 bash는 3.x)
    if [ "${OS}" = "macos" ]; then
        local bash_major
        bash_major=$(/opt/homebrew/bin/bash --version 2>/dev/null | head -1 | grep -oE '[0-9]+' | head -1)
        if [ -z "${bash_major}" ] || [ "${bash_major}" -lt 4 ]; then
            info "Bash 4+ 설치 중 (SDKMAN 요구사항)..."
            brew install bash
        fi
        ok "Bash 4+: $(/opt/homebrew/bin/bash --version | head -1)"
    fi
}

# ─── 3.5. SDKMAN + Java 설치 ───
install_java() {
    if [ -d "${HOME}/.sdkman" ]; then
        ok "SDKMAN 이미 설치됨"
    else
        info "SDKMAN 설치 중..."
        if [ "${OS}" = "macos" ]; then
            /opt/homebrew/bin/bash -c 'curl -s "https://get.sdkman.io" | bash' 2>/dev/null
        else
            curl -s "https://get.sdkman.io" | bash 2>/dev/null
        fi
        ok "SDKMAN 설치 완료"
    fi

    # SDKMAN 초기화 함수
    local sdk_bash="bash"
    [ "${OS}" = "macos" ] && sdk_bash="/opt/homebrew/bin/bash"

    # Java 21 설치 (jdtls 실행용, 없으면 설치)
    # SDKMAN 첫 설치 직후에는 candidates/java가 없어 find가 실패하므로 `|| true` 필요 (pipefail)
    local has_java21
    has_java21=$(find "${HOME}/.sdkman/candidates/java" -maxdepth 1 -name "21*" -type d 2>/dev/null | head -1 || true)
    if [ -z "${has_java21}" ]; then
        info "Java 21 설치 중 (Temurin)..."
        ${sdk_bash} -c 'source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install java 21.0.10-tem <<< "Y"' 2>/dev/null || true
        ok "Java 21 설치 완료"
    else
        ok "Java 21 이미 설치됨: ${has_java21}"
    fi

    # Java 8 설치 (선택, 없으면 설치)
    local has_java8
    has_java8=$(find "${HOME}/.sdkman/candidates/java" -maxdepth 1 -name "8*" -type d 2>/dev/null | head -1 || true)
    if [ -z "${has_java8}" ]; then
        info "Java 8 설치 중 (Zulu)..."
        ${sdk_bash} -c 'source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install java 8.0.482-zulu <<< "n"' 2>/dev/null || true
        ok "Java 8 설치 완료"
    else
        ok "Java 8 이미 설치됨: ${has_java8}"
    fi
}

# ─── 3.6. Nerd Font 설치 (아이콘 표시용) ───
install_nerd_font() {
    # 이미 설치 여부 확인
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono.*Nerd"; then
        ok "Nerd Font 이미 설치됨"
        return
    fi

    info "JetBrainsMono Nerd Font 설치 중..."
    case "${OS}" in
        macos)
            brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
            ;;
        linux)
            local font_dir="${HOME}/.local/share/fonts"
            mkdir -p "${font_dir}"
            curl -fLo "/tmp/JetBrainsMono.zip" \
                "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
            unzip -o /tmp/JetBrainsMono.zip -d "${font_dir}" 2>/dev/null
            fc-cache -fv 2>/dev/null || true
            rm -f /tmp/JetBrainsMono.zip
            ;;
    esac
    ok "Nerd Font 설치 완료 (터미널 폰트를 JetBrainsMono Nerd Font로 변경하세요)"
}

# ─── 4. 설정 파일 배치 ───
setup_config() {
    if [ "${SCRIPT_DIR}" = "${NVIM_CONFIG_DIR}" ]; then
        ok "설정이 이미 올바른 위치에 있습니다: ${NVIM_CONFIG_DIR}"
        return
    fi

    if [ -d "${NVIM_CONFIG_DIR}" ]; then
        local backup="${NVIM_CONFIG_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        warn "기존 설정을 백업합니다: ${backup}"
        mv "${NVIM_CONFIG_DIR}" "${backup}"
    fi

    info "설정 심볼릭 링크 생성: ${SCRIPT_DIR} -> ${NVIM_CONFIG_DIR}"
    mkdir -p "$(dirname "${NVIM_CONFIG_DIR}")"
    ln -sf "${SCRIPT_DIR}" "${NVIM_CONFIG_DIR}"
    ok "설정 배치 완료"
}

# ─── 5. 플러그인 설치 ───
install_plugins() {
    info "플러그인 설치 중 (lazy.nvim)..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    ok "플러그인 설치 완료"
}

# ─── 6. LSP 서버 설치 ───
install_lsp_servers() {
    info "LSP 서버 설치 중 (Mason)..."
    # gopls는 Mason이 `go install`로 빌드하므로 Go가 있을 때만 설치
    local servers="pyright jdtls lua-language-server"
    if command -v go &>/dev/null; then
        servers="gopls ${servers}"
    else
        warn "Go가 없어 gopls 설치를 건너뜁니다 (Go 설치 후 :MasonInstall gopls)"
    fi
    nvim --headless "+MasonInstall ${servers}" "+sleep 30" +qa 2>/dev/null || true
    ok "LSP 서버 설치 완료 (일부는 Neovim 첫 실행 시 자동 완료됩니다)"
}

# ─── 실행 ───
main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║   Neovim 환경 자동 설치 스크립트     ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    detect_os
    install_neovim
    install_dependencies
    install_java
    install_nerd_font
    setup_config
    install_plugins
    install_lsp_servers

    echo ""
    ok "━━━ 설치가 완료되었습니다! ━━━"
    echo ""
    info "시작하기: nvim"
    info "첫 실행 시 Treesitter 파서가 자동으로 설치됩니다."
    info "포매터 설치: nvim 실행 후 :MasonInstall gofumpt goimports black stylua prettier"
    echo ""
}

main "$@"

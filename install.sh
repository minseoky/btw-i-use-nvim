#!/usr/bin/env bash
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
install_neovim() {
    if command -v nvim &>/dev/null; then
        ok "Neovim 이미 설치됨: $(nvim --version | head -1)"
        return
    fi

    info "Neovim 설치 중..."
    case "${OS}" in
        macos)
            if command -v brew &>/dev/null; then
                brew install neovim
            else
                error "Homebrew가 필요합니다. https://brew.sh 에서 설치하세요."
            fi
            ;;
        linux)
            if command -v apt-get &>/dev/null; then
                ${SUDO} apt-get update
                if grep -qi ubuntu /etc/os-release 2>/dev/null; then
                    # Ubuntu - PPA에서 최신 버전 설치
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
            else
                # 범용 fallback: AppImage
                info "패키지 매니저를 찾을 수 없어 AppImage로 설치합니다..."
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
                chmod u+x nvim.appimage
                ${SUDO} mv nvim.appimage /usr/local/bin/nvim
            fi
            ;;
    esac
    ok "Neovim 설치 완료: $(nvim --version | head -1)"
}

# ─── 3. 필수 도구 설치 ───
install_dependencies() {
    local deps=()

    command -v rg  &>/dev/null || deps+=("ripgrep")
    command -v fd  &>/dev/null || deps+=("fd")
    command -v git &>/dev/null || deps+=("git")
    command -v node &>/dev/null || deps+=("node")

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
    local has_java21
    has_java21=$(find "${HOME}/.sdkman/candidates/java" -maxdepth 1 -name "21*" -type d 2>/dev/null | head -1)
    if [ -z "${has_java21}" ]; then
        info "Java 21 설치 중 (Temurin)..."
        ${sdk_bash} -c 'source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install java 21.0.10-tem <<< "Y"' 2>/dev/null || true
        ok "Java 21 설치 완료"
    else
        ok "Java 21 이미 설치됨: ${has_java21}"
    fi

    # Java 8 설치 (선택, 없으면 설치)
    local has_java8
    has_java8=$(find "${HOME}/.sdkman/candidates/java" -maxdepth 1 -name "8*" -type d 2>/dev/null | head -1)
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
    nvim --headless "+MasonInstall gopls pyright jdtls lua-language-server" "+sleep 30" +qa 2>/dev/null || true
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

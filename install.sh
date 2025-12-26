#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_info "Detected macOS"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            arch|manjaro)
                OS="arch"
                print_info "Detected Arch-based system"
                ;;
            debian)
                OS="debian"
                print_info "Detected Debian"
                ;;
            ubuntu)
                OS="ubuntu"
                print_info "Detected Ubuntu"
                ;;
            fedora)
                OS="fedora"
                print_info "Detected Fedora"
                ;;
            *)
                print_error "Unsupported distribution: $ID"
                exit 1
                ;;
        esac
    else
        print_error "Unable to detect operating system"
        exit 1
    fi
}

install_packages() {
    print_info "Installing system packages..."

    case "$OS" in
        arch)
            sudo pacman -Syu --needed --noconfirm \
                base-devel \
                git \
                curl \
                wget \
                zsh \
                neovim \
                tmux \
                ripgrep \
                fd \
                fzf \
                eza \
                lazygit \
                starship \
                zoxide \
                nodejs \
                npm \
                python \
                python-pip \
                lua \
                luarocks \
                gcc \
                clang \
                make \
                cmake \
                unzip \
                xsel \
                wl-clipboard \
                go \
                rust \
                jdk-openjdk \
                pyright \
                lua-language-server \
                gopls \
                rust-analyzer \
                stylua \
                prettier

            if ! command -v yay &> /dev/null; then
                print_info "Installing yay AUR helper..."
                cd /tmp
                git clone https://aur.archlinux.org/yay.git
                cd yay
                makepkg -si --noconfirm
                cd -
            fi

            yay -S --needed --noconfirm \
                zsh-syntax-highlighting \
                zsh-autosuggestions \
                clang-format
            ;;

        debian|ubuntu)
            sudo apt update
            sudo apt install -y \
                build-essential \
                git \
                curl \
                wget \
                zsh \
                tmux \
                ripgrep \
                fd-find \
                fzf \
                nodejs \
                npm \
                python3 \
                python3-pip \
                lua5.4 \
                luarocks \
                gcc \
                clang \
                clang-format \
                make \
                cmake \
                unzip \
                xsel \
                wl-clipboard \
                golang \
                cargo \
                rustc \
                default-jdk \
                software-properties-common

            if [[ "$OS" == "ubuntu" ]]; then
                sudo add-apt-repository -y ppa:neovim-ppa/unstable
                sudo apt update
                sudo apt install -y neovim
            else
                sudo apt install -y neovim
            fi

            if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
                sudo ln -sf $(which fdfind) /usr/local/bin/fd
            fi

            if ! command -v eza &> /dev/null; then
                print_info "Installing eza..."
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                sudo apt update
                sudo apt install -y eza
            fi

            if ! command -v lazygit &> /dev/null; then
                print_info "Installing lazygit..."
                LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                tar xf lazygit.tar.gz lazygit
                sudo install lazygit /usr/local/bin
                rm lazygit lazygit.tar.gz
            fi

            if ! command -v starship &> /dev/null; then
                print_info "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi

            if ! command -v zoxide &> /dev/null; then
                print_info "Installing zoxide..."
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi

            if [[ ! -d /usr/share/zsh-syntax-highlighting ]]; then
                sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting
            fi
            if [[ ! -d /usr/share/zsh-autosuggestions ]]; then
                sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions
            fi
            ;;

        fedora)
            sudo dnf install -y \
                @development-tools \
                git \
                curl \
                wget \
                zsh \
                neovim \
                tmux \
                ripgrep \
                fd-find \
                fzf \
                nodejs \
                npm \
                python3 \
                python3-pip \
                lua \
                luarocks \
                gcc \
                clang \
                clang-tools-extra \
                make \
                cmake \
                unzip \
                xsel \
                wl-clipboard \
                golang \
                cargo \
                rust \
                java-latest-openjdk \
                java-latest-openjdk-devel

            if ! command -v eza &> /dev/null; then
                print_info "Installing eza..."
                sudo dnf install -y eza
            fi

            if ! command -v lazygit &> /dev/null; then
                print_info "Installing lazygit..."
                sudo dnf copr enable atim/lazygit -y
                sudo dnf install -y lazygit
            fi

            if ! command -v starship &> /dev/null; then
                print_info "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi

            if ! command -v zoxide &> /dev/null; then
                print_info "Installing zoxide..."
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi

            if [[ ! -d /usr/share/zsh-syntax-highlighting ]]; then
                sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting
            fi
            if [[ ! -d /usr/share/zsh-autosuggestions ]]; then
                sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions
            fi
            ;;

        macos)
            if ! command -v brew &> /dev/null; then
                print_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                if [[ $(uname -m) == "arm64" ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi

            print_info "Installing packages via Homebrew..."
            brew install \
                git \
                curl \
                wget \
                zsh \
                neovim \
                tmux \
                ripgrep \
                fd \
                fzf \
                eza \
                lazygit \
                starship \
                zoxide \
                node \
                python3 \
                lua \
                luarocks \
                gcc \
                llvm \
                make \
                cmake \
                go \
                rust \
                openjdk \
                zsh-syntax-highlighting \
                zsh-autosuggestions

            if [[ -d /opt/homebrew/opt/openjdk ]]; then
                sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
            fi
            ;;
    esac

    print_success "System packages installed successfully"
}

install_npm_packages() {
    print_info "Installing npm packages..."

    if command -v npm &> /dev/null; then
        npm install -g \
            pyright \
            prettier \
            typescript \
            typescript-language-server \
            neovim
        print_success "npm packages installed successfully"
    else
        print_warning "npm not found, skipping npm packages"
    fi
}

install_python_packages() {
    print_info "Installing Python packages..."

    if command -v pip3 &> /dev/null; then
        pip3 install --user pynvim
        print_success "Python packages installed successfully"
    else
        print_warning "pip3 not found, skipping Python packages"
    fi
}

install_lua_packages() {
    print_info "Installing Lua packages..."

    if command -v luarocks &> /dev/null; then
        luarocks install --local luacheck
        print_success "Lua packages installed successfully"
    else
        print_warning "luarocks not found, skipping Lua packages"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "oh-my-zsh installed successfully"
    else
        print_info "oh-my-zsh already installed"
    fi

    if [[ "$OS" == "macos" ]]; then
        print_info "zsh plugins installed via Homebrew"
    else
        if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
                "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
        fi

        if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions \
                "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
        fi
    fi
}

install_tpm() {
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        print_success "TPM installed successfully"
    else
        print_info "TPM already installed"
    fi
}

setup_dotfiles() {
    print_info "Setting up dotfiles..."

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    backup_if_exists() {
        if [[ -e "$1" ]] && [[ ! -L "$1" ]]; then
            print_warning "Backing up existing $1 to $1.backup"
            mv "$1" "$1.backup"
        fi
    }

    mkdir -p "$HOME/.config"

    backup_if_exists "$HOME/.zshrc"
    ln -sf "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
    print_success "Linked .zshrc"

    backup_if_exists "$HOME/.tmux.conf"
    ln -sf "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
    print_success "Linked .tmux.conf"

    backup_if_exists "$HOME/.config/nvim"
    ln -sf "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
    print_success "Linked nvim config"

    if [[ -d "$SCRIPT_DIR/.config/kitty" ]]; then
        backup_if_exists "$HOME/.config/kitty"
        ln -sf "$SCRIPT_DIR/.config/kitty" "$HOME/.config/kitty"
        print_success "Linked kitty config"
    fi

    if [[ -d "$SCRIPT_DIR/.config/starship.toml" ]]; then
        backup_if_exists "$HOME/.config/starship.toml"
        ln -sf "$SCRIPT_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
        print_success "Linked starship config"
    fi

    if [[ -d "$SCRIPT_DIR/.config/yazi" ]]; then
        backup_if_exists "$HOME/.config/yazi"
        ln -sf "$SCRIPT_DIR/.config/yazi" "$HOME/.config/yazi"
        print_success "Linked yazi config"
    fi

    print_success "Dotfiles linked successfully"
}

setup_nvim() {
    print_info "Setting up Neovim..."

    print_info "Neovim plugins will be installed on first run via lazy.nvim"

    mkdir -p "$HOME/.local/share/nvim"

    print_success "Neovim setup complete"
}

change_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        print_info "Changing default shell to zsh..."

        if command -v zsh &> /dev/null; then
            ZSH_PATH=$(which zsh)

            if ! grep -q "$ZSH_PATH" /etc/shells; then
                print_info "Adding zsh to /etc/shells..."
                echo "$ZSH_PATH" | sudo tee -a /etc/shells
            fi

            chsh -s "$ZSH_PATH"
            print_success "Default shell changed to zsh"
            print_warning "Please log out and log back in for the shell change to take effect"
        else
            print_error "zsh not found in PATH"
        fi
    else
        print_info "Default shell is already zsh"
    fi
}

main() {
    echo "╔════════════════════════════════════════╗"
    echo "║   Dotfiles Installation Script         ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    detect_os
    echo ""

    read -p "This script will install packages and setup dotfiles. Continue? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi

    install_packages
    echo ""

    install_npm_packages
    echo ""

    install_python_packages
    echo ""

    install_lua_packages
    echo ""

    install_oh_my_zsh
    echo ""

    install_tpm
    echo ""

    setup_dotfiles
    echo ""

    setup_nvim
    echo ""

    change_shell
    echo ""

    print_success "Installation complete!"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Open tmux and press Ctrl-a + I to install tmux plugins"
    echo "  3. Open nvim - plugins will install automatically via lazy.nvim"
    echo "  4. Run :checkhealth in nvim to verify everything is working"
    echo ""
    print_warning "Some changes may require logging out and back in to take effect"
}

main

#!/usr/bin/env bash
#
#
#  ███▄ ▄███▓ ▄▄▄       ▄████▄   ▒█████    ██████      ██████ ▓█████▄▄▄█████▓ █    ██  ██▓███  
# ▓██▒▀█▀ ██▒▒████▄    ▒██▀ ▀█  ▒██▒  ██▒▒██    ▒    ▒██    ▒ ▓█   ▀▓  ██▒ ▓▒ ██  ▓██▒▓██░  ██▒
# ▓██    ▓██░▒██  ▀█▄  ▒▓█    ▄ ▒██░  ██▒░ ▓██▄      ░ ▓██▄   ▒███  ▒ ▓██░ ▒░▓██  ▒██░▓██░ ██▓▒
# ▒██    ▒██ ░██▄▄▄▄██ ▒▓▓▄ ▄██▒▒██   ██░  ▒   ██▒     ▒   ██▒▒▓█  ▄░ ▓██▓ ░ ▓▓█  ░██░▒██▄█▓▒ ▒
# ▒██▒   ░██▒ ▓█   ▓██▒▒ ▓███▀ ░░ ████▓▒░▒██████▒▒   ▒██████▒▒░▒████▒ ▒██▒ ░ ▒▒█████▓ ▒██▒ ░  ░
# ░ ▒░   ░  ░ ▒▒   ▓▒█░░ ░▒ ▒  ░░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░   ▒ ▒▓▒ ▒ ░░░ ▒░ ░ ▒ ░░   ░▒▓▒ ▒ ▒ ▒▓▒░ ░  ░
# ░  ░      ░  ▒   ▒▒ ░  ░  ▒     ░ ▒ ▒░ ░ ░▒  ░ ░   ░ ░▒  ░ ░ ░ ░  ░   ░    ░░▒░ ░ ░ ░▒ ░     
# ░      ░     ░   ▒   ░        ░ ░ ░ ▒  ░  ░  ░     ░  ░  ░     ░    ░       ░░░ ░ ░ ░░       
#        ░         ░  ░░ ░          ░ ░        ░           ░     ░  ░           ░              
#                      ░
#
# last updated: 21.08.2023


set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes


generate-new-ssh-key() {
    local keyname="${1}"
    local keypath="${2}"
    
    read -p "Enter a new SSH key comment: " comment

    if [ -z "$comment" ]
    then
        echo "Please provide a comment for your new ssh key, i.e email or machine name"
        return 1
    fi
    
    if [ ! -d "$keypath" ]
    then
        mkdir -p "$keypath"
        chmod 700 "$keypath"
    fi

    ssh-keygen -t ed25519 -C "$comment" -f "${keypath}/${keyname}"
}

add-ssh-key-to-agent() {
    local keyname="${1}"
    local keypath="${2}"

    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "${keypath}/${keyname}"
}

add-ssh-host-config-entry() {
    local keyname="${1}"
    local keypath="${2}"
    local host="${3}"
    local identity="${keypath}/${keyname}"
    local config="$HOME/.ssh/config"

    if [ ! -f "$config" ]
    then
        echo "No config $config found. Creating $config with permissions 664."
        touch "$config"
        chmod 644 "$config"
    fi

    if ! grep -q "Host $host" "$config"
    then
        {
            echo "Host $host"
            echo "    AddKeysToAgent yes"
            echo "    UseKeychain yes"
            echo "    IdentityFile ${identity}"
            echo
        } >> "$config"

        echo "SSH configuration added for $host"
    else
        echo "SSH configuration lines for $host already exist in $config."
    fi
}

known-hosts-bitbucket() {
    # https://bitbucket.org/site/ssh
    echo "bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQeJzhupRu0u0cdegZIa8e86EG2qOCsIsD1Xw0xSeiPDlCr7kq97NLmMbpKTX6Esc30NuoqEEHCuc7yWtwp8dI76EEEB1VqY9QJq6vk+aySyboD5QF61I/1WeTwu+deCbgKMGbUijeXhtfbxSxm6JwGrXrhBdofTsbKRUsrN1WoNgUa8uqN1Vx6WAJw1JHPhglEGGHea6QICwJOAr/6mrui/oB7pkaWKHj3z7d1IC4KWLtY47elvjbaTlkN04Kc/5LFEirorGYVbt15kAUlqGM65pk6ZBxtaO3+30LVlORZkxOh+LKL/BvbZ/iRNhItLqNyieoQj/uh/7Iv4uyH/cV/0b4WDSd3DptigWq84lJubb9t/DnZlrJazxyDCulTmKdOR7vs9gMTo+uoIrPSb8ScTtvw65+odKAlBj59dhnVp9zd7QUojOpXlL62Aw56U4oO+FALuevvMjiWeavKhJqlR7i5n9srYcrNV7ttmDw7kf/97P5zauIhxcjX+xHv4M="
    echo "bitbucket.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPIQmuzMBuKdWeF4+a2sjSSpBK0iqitSQ+5BM9KhpexuGt20JpTVM7u5BDZngncgrqDMbWdxMWWOGtZ9UgbqgZE="
    echo "bitbucket.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIazEu89wgQZ4bqs3d63QSMzYVa0MuJ2e2gKTKqu+UUO"
}

known-hosts-github() {
    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    echo "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
}

populate-ssh-known-hosts() {
    local hosts="$HOME/.ssh/known_hosts"
    
    if [ ! -f "$hosts" ]
    then
        touch "$hosts"
        chmod 644 "$hosts"
        echo "Created $hosts with permissions 644."
        
        known-hosts-github >> "$hosts"
        echo "Added github.com public keys to $hosts"
        
        known-hosts-bitbucket >> "$hosts"
        echo "Added bitbucket.org public keys to $hosts"
    else
        echo "$hosts already exists, skipping."
    fi
}

setup-ssh() {
    local keyname="${1:-ed25519}"
    local keypath="${2:-$HOME/.ssh}"

    generate-new-ssh-key "${keyname}" "${keypath}"
    add-ssh-key-to-agent "${keyname}" "${keypath}"
    
    add-ssh-host-config-entry "${keyname}" "${keypath}" "github.com"
    add-ssh-host-config-entry "${keyname}" "${keypath}" "bitbucket.org"

    populate-ssh-known-hosts
}

install-homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
}

install-packages() {
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    # Taps
    brew tap 'homebrew/cask-fonts'

    brew update

    # Fonts
    brew install 'font-ubuntu'
    brew install 'font-ubuntu-condensed'
    brew install 'font-ubuntu-mono'
    brew install 'font-fira-code'
    brew install 'font-jetbrains-mono'

    # Formulas
    brew install 'coreutils'
    brew install 'tree'
    brew install 'nvm'
    brew install 'pyenv'
    brew install 'ripgrep'
    brew install 'jq'

    brew install 'zsh-autopair'
    brew install 'zsh-completions'

    brew install 'pipx'
    pipx ensurepath

    # Casks
    brew install --cask 'arc'
    brew install --cask 'iterm2'
    brew install --cask 'raycast'
    brew install --cask 'google-chrome'
    brew install --cask 'visual-studio-code'
    brew install --cask 'docker'
    brew install --cask 'figma'
    brew install --cask 'signal'
    brew install --cask 'slack'
}

setup-packages() {
    if [ ! -e "/opt/homebrew/bin/brew" ]
    then
        install-homebrew
    fi
    
    install-packages
}

setup-settings() {
    # https://macos-defaults.com/
    (
        set -o xtrace
        defaults write com.apple.dock tilesize -int "50"
        defaults write com.apple.dock autohide -bool "true"
        defaults write com.apple.dock autohide-delay -float "0.1"
        defaults write com.apple.dock show-recents -bool "false"
        defaults write com.apple.finder AppleShowAllFiles -bool "false"
        defaults write com.apple.finder ShowPathbar -bool "true"
        defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
        defaults write com.apple.finder FXRemoveOldTrashItems -bool "true"
        defaults write com.apple.finder ShowHardDrivesOnDesktop -bool "false"
        defaults write com.apple.ActivityMonitor UpdatePeriod -int "2"
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool "false"
    )
}

setup-dotfiles() {
    local projects=~/prj

    if [ ! -d "$projects" ]
    then
        mkdir -p "$projects"
    fi

    git clone git@github.com:psmolak/dotfiles.git "${projects}/dotfiles"
    "${projects}/dotfiles/install.sh"
}

# TODO: move this to ~/.gitconfig
enforce-git-local-identity() {
    # remove any existing global identity
    git config --global --unset user.name
    git config --global --unset user.email
    git config --global --unset user.signingkey

    # require local config to exist in order to make commits
    git config --global user.useConfigOnly true
}

post-setup() {
    echo "* https://www.frontendreference.com/disable-adding-period-with-double-space-ventura.html"
    echo "* disable indexing for Spotlight for home directory"
    echo "* add your fresh ssh key to github.com & bitbucket.org"
}

main() {
    case "$1" in
        "ssh")        setup-ssh ;;
        "packages")   setup-packages ;;
        "dotfiles")   setup-dotfiles ;;
        "settings")   setup-settings ;;
        "post-setup") post-setup ;;

        "all")
            setup-ssh
            setup-packages
            setup-dotfiles
            setup-settings
            post-setup
            ;;

        *) echo "Usage: ./setup.sh ssh | packages | dotfiles | settings | post-setup" ;;
    esac
}

main "$@"

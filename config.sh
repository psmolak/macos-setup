# https://macos-defaults.com/
# https://www.frontendreference.com/disable-adding-period-with-double-space-ventura.html

# Settings
defaults write com.apple.dock tilesize -int "50"
defaults write com.apple.dock autohide -bool "true"
defaults write com.apple.dock autohide-delay -float "0.1"
defaults write com.apple.dock show-recents -bool "false"
defaults write com.apple.finder AppleShowAllFiles -bool "true"
defaults write com.apple.finder ShowPathbar -bool "true"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXRemoveOldTrashItems -bool "true"
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool "false"
defaults write com.apple.ActivityMonitor UpdatePeriod -int "2"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool "false"

if which git
then
    # remove any existing global identity
    git config --global --unset user.name
    git config --global --unset user.email
    git config --global --unset user.signingkey

    # require local config to exist in order to make commits
    git config --global user.useConfigOnly true
fi

# TODO: add / root path to ignored path in Spotlight privacy settings
# to disable indexing

# https://github.com/tmm/dotfiles/blob/main/Brewfile

# TODO: first install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Taps
brew tap 'homebrew/cask-fonts'

brew update

# Fonts
brew install 'font-ubuntu'
brew install 'font-ubuntu-condensed'
brew install 'font-ubuntu-mono'

# Formulas
brew install 'nvm'
brew install 'pyenv'
brew install 'helix'
brew install 'coreutils'

brew install 'zsh-autopair'
brew install 'zsh-completions'

# Casks
brew install 'arc'
brew install 'iterm2'
brew install 'raycast'
brew install 'google-chrome'
brew install 'visual-studio-code'

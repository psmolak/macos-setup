# https://macos-defaults.com/

# https://www.frontendreference.com/disable-adding-period-with-double-space-ventura.html

# enable key repeat when hold
defaults write -g ApplePressAndHoldEnabled -bool false

# disable font-smoothing [ disabled (0), light (1), medium (2), strong (3) ]
defaults -currentHost write -g AppleFontSmoothing -int 2

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

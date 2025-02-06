if status is-interactive
    # Commands to run in interactive sessions can go here
end


fish_vi_key_bindings
set fish_greeting ""


set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /run/current-system/sw/bin $PATH
set -gx PATH ~/.cargo/bin $PATH
set -gx PATH ~/go/bin $PATH

set EDITOR 'nvim'


alias vim=nvim
alias ls='eza --icons --all'
alias lg=lazygit
zoxide init fish | source
starship init fish | source

#set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
#mkdir -p ~/.config/fish/completions
#carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
#carapace _carapace | source

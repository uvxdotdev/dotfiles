if status is-interactive
end


fish_vi_key_bindings
bind --mode insert --sets-mode default jj repaint
bind --mode insert --sets-mode default jk repaint
set fish_greeting ""


set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /run/current-system/sw/bin $PATH
set -gx PATH ~/.cargo/bin $PATH
set -gx PATH ~/go/bin $PATH
set -gx PATH ~/.npm-global/bin $PATH

set EDITOR 'nvim'
set SHELL '/run/current-system/sw/bin/fish'
set NVIM_APPNAME 'nvim-new'

# set OPENAI_API_KEY "sk-vzbNRbC9hWHqq2DsS6lxDi4jeCA1tz5nbpCGvB0blZlE1PP5"
set OPENAI_API_KEY "sk-uv"

set TERM xterm-256color


alias vim=nvim
alias ls='eza --icons --all'
alias lg=lazygit
alias ld=lazydocker
alias rf=rainfrog
alias minecraft='java -jar ~/minecraft/launcher.jar'

alias nu='sudo darwin-rebuild switch --flake ~/nix#Utkarshs-MacBook-Pro'

alias act='source ./.venv/bin/activate.fish; set -gx PATH ~/.npm-global/bin $PATH'

# starship init fish | source

# set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
# carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
# carapace _carapace | source





function qt
    if test (count $argv) -eq 0
        echo "Usage: qt <mediafile>"
        return 1
    end

    set filepath (realpath $argv[1])

    osascript -e "
    tell application \"QuickTime Player\"
        activate
        set theMedia to open (POSIX file \"$filepath\")
        play theMedia
    end tell
    "
end

function knt
    set line_count (sudo launchctl list | grep example | wc -l)
    echo $line_count

    if test $line_count -eq 3
        echo "Kanata is running"
        sudo launchctl bootout system/com.example.kanata
        echo "Kanata stopped"
    else
        echo "Kanata is not running"
        sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.kanata.plist
        sudo launchctl enable system/com.example.kanata.plist
        sudo launchctl start com.example.kanata
        echo "Kanata started"
    end
end


starship init fish | source
direnv hook fish | source
zoxide init fish | source
# uv
fish_add_path "/Users/uvx/.bun/bin"

$env.SHELL = '/run/current-system/sw/bin/nu'

# Nushell Environment Config File
#
# version = "0.99.1"

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)

path add /opt/homebrew/bin
path add /run/current-system/sw/bin
path add ~/.cargo/bin
path add ~/go/bin

# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')



$env.EDITOR = 'nvim'
$env.DYLD_LIBRARY_PATH = '/opt/homebrew/lib/'

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional

$env.TERM = 'xterm-256color'
$env.PEREC_DIR = '/Users/utkarshverma/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main'

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

zoxide init nushell | save -f ~/.zoxide.nu

# mkdir ~/.cache/starship
# starship init nu | save -f ~/.cache/starship/init.nu

oh-my-posh init nu --config ~/.config/ohmyposh/config.toml


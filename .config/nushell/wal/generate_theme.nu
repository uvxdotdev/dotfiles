def generate_theme [] {
# Change to the Backgrounds directory
    cd ~/Backgrounds

# Create a temporary file to store fzf's selection
    let temp_file = (mktemp)

# Run fzf and save selection to the temp file
    ls | each { |entry| $entry.name } | to text | fzf --preview "sh ~/.config/nushell/wal/fzf-preview.sh {}" | save $temp_file -f

# Read the selection from the temp file
    let selection = (open $temp_file | str trim)

# If a selection was made (file isn't empty)
    if ($selection | str length) > 0 {
        # Form the full path to the selected image
        let full_path = $"($env.PWD)/($selection)"
        
        # Print the selected path (for debugging)
        echo $"Selected wallpaper: ($full_path)"
        
        # Generate color scheme with pywal (without quotes in the path)
        ^wal -i ($full_path | path expand) --cols16 --backend okthief
        
        # Set as wallpaper using osascript
        osascript ~/.config/nushell/wal/set_wallpaper.scpt ($full_path | path expand)

        kitty-to-ghostty
        uv run ~/.config/nushell/wal/nushell_theme_generater.py
        
        # Print confirmation
        echo "Wallpaper has been set and color scheme generated!"
    } else {
        echo "No selection was made."
    }

# Clean up the temporary file
    rm $temp_file

}

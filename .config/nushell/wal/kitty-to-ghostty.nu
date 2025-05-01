def kitty-to-ghostty [
    kitty_config_path: string = "~/.cache/wal/colors-kitty.conf",  # Path to the kitty.conf file
    ghostty_config_path: string = "~/.config/ghostty/themes/wal"  # Path for the output ghostty config file
] {
    # Expand paths to handle tilde (~) and environment variables
    let expanded_kitty_path = ($kitty_config_path | path expand)
    let expanded_ghostty_path = ($ghostty_config_path | path expand)
    
    # Check if file exists
    if not ($expanded_kitty_path | path exists) {
        return {
            status: "error",
            message: $"File not found: ($kitty_config_path)",
            expanded_path: $expanded_kitty_path
        }
    }
    
    # Read the kitty config file
    let kitty_content = (open $expanded_kitty_path | lines)
    
    # Initialize an empty record for parsed values
    mut config = {}
    
    # Process each line in the kitty config
    for line in $kitty_content {
        let trimmed = ($line | str trim)
        
        # Skip empty lines and comments
        if ($trimmed | str length) == 0 or ($trimmed | str starts-with "#") {
            continue
        }
        
        # Try to parse the line as a key-value pair
        let parts = ($trimmed | split row -n 2 " ")
        if ($parts | length) >= 2 {
            let key = ($parts | get 0)
            let value = ($parts | get 1 | str trim)
            
            # Store in our config object
            $config = ($config | merge {$key: $value})
        }
    }
    
    # Start building the ghostty config
    mut ghostty_lines = []
    
    # Convert foreground and background
    if "foreground" in $config {
        $ghostty_lines = ($ghostty_lines | append $"foreground = ($config.foreground)")
    }
    
    if "background" in $config {
        $ghostty_lines = ($ghostty_lines | append $"background = ($config.background)")
    }
    
    # Convert background opacity if it exists
    if "background_opacity" in $config {
        $ghostty_lines = ($ghostty_lines | append $"background-opacity = ($config.background_opacity)")
    }
    
    # Convert cursor color
    if "cursor" in $config {
        $ghostty_lines = ($ghostty_lines | append $"cursor-color = ($config.cursor)")
        $ghostty_lines = ($ghostty_lines | append $"cursor-text = ($config.background)")
    }
    
    # Convert color palette (0-15)
    for i in 0..15 {
        let color_key = $"color($i)"
        if $color_key in $config {
            $ghostty_lines = ($ghostty_lines | append $"palette = ($i)=($config | get $color_key)")
        }
    }
    
    # Convert selection colors (approximating from tab colors)
    if "active_tab_background" in $config {
        $ghostty_lines = ($ghostty_lines | append $"selection-background = ($config.active_tab_background)")
    }
    
    if "active_tab_foreground" in $config {
        $ghostty_lines = ($ghostty_lines | append $"selection-foreground = ($config.active_tab_foreground)")
    }
    
    # Save the ghostty config to file
    $ghostty_lines | str join "\n" | save -f $expanded_ghostty_path
    
    # Return success message
    {
        status: "success",
        source: $kitty_config_path,
        expanded_source: $expanded_kitty_path,
        destination: $ghostty_config_path,
        expanded_destination: $expanded_ghostty_path,
        lines_converted: ($ghostty_lines | length)
    }
}

# Example usage:
# kitty-to-ghostty "~/.config/kitty/kitty.conf" "~/.config/ghostty/config"

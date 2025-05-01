on run argv
    set imagePath to item 1 of argv
    tell application "System Events"
        tell every desktop
            set picture to imagePath
        end tell
    end tell
end run

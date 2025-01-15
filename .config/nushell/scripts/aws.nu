def get-pipeline-status [] {
    # Parse the input JSON and extract stageStates
    let pipeline = $in | from json | get stageStates
    
    # Create a table with stage names and their statuses
    $pipeline | each {|stage| 
        # Directly access the status from latestExecution
        let status = $stage.latestExecution.status
        
        # Create a colored status based on the value
        let colored_status = if $status == null {
            $'(ansi blue)Not Started'
        } else {
            match $status {
                "Succeeded" => $'(ansi green)($status)',
                "Failed" => $'(ansi red)($status)',
                "InProgress" => $'(ansi yellow)($status)',
                _ => $'(ansi blue)($status)' 
            }
        }
        
        {
            Stage: $stage.stageName,
            Status: $colored_status
        }
    } | table
}

# Helper function to get table details
def get-table-info [table_name: string] {
    # Get table description
    let table_desc = (aws dynamodb describe-table --table-name $table_name | from json)
    
    # Format basic table info
    let info = [
        $"Table: ($table_name)",
        $"Items: (aws dynamodb scan --table-name $table_name --select COUNT | from json | get Count)",
        $"Status: ($table_desc.Table.TableStatus)",
        $"Size: ($table_desc.Table.TableSizeBytes | into filesize)",
        "─────────────────────",
        "Attributes:",
        ($table_desc.Table.AttributeDefinitions | each {|attr| 
            $"  ($attr.AttributeName) (($attr.AttributeType))"
        } | str join "\n"),
        "─────────────────────",
        "Keys:",
        ($table_desc.Table.KeySchema | each {|key| 
            $"  ($key.AttributeName) (($key.KeyType))"
        } | str join "\n")
    ] | str join "\n"
    
    $info
}

# Helper function to explore table contents
def explore-table [table_name: string] {
    # Get all items
    let items = (aws dynamodb scan --table-name $table_name | from json | get Items)
    
    let selected_item = ($items | fzf --preview "{} | table")
    
    if ($selected_item | is-empty) {
        return "No item selected"
    }
    
    # Convert the selected item back to structured data
    let item_map = (echo $selected_item | from yaml)
    
    # Allow fuzzy search within selected row's attributes
    let selected_attr = ($item_map | each {|entry| $"($entry.key): ($entry.value)" } | str join "\n" | fzf --header "Attributes in the selected row")
    
    if ($selected_attr | is-empty) {
        return "No attribute selected"
    }
    
    $"Selected attribute: ($selected_attr)"
}
# Main explorer function
def explore-dynamodb-tables [] {
    # Get list of all tables
    let tables = (aws dynamodb list-tables | from json | get TableNames)
    
    # Create preview command for fzf
    let preview_cmd = "aws dynamodb describe-table --table-name {} | from json | get Table | to yaml"
    
    # Use fzf to select table with preview
    let selected = ($tables | str join "\n" | fzf --preview $preview_cmd)
    
    if ($selected | is-empty) {
        return "No table selected"
    }
    
    # Show table exploration menu
    let action = ([
        "View table info",
        "Explore items (scrollable)",
        "Exit"
    ] | str join "\n" | fzf --header $"Selected table: ($selected)")
    
    match $action {
        "View table info" => { get-table-info $selected },
        "Explore items (scrollable)" => { explore-table $selected },
        _ => { "Exiting..." }
    }
}

# Command to start exploration
# explore-dynamodb-tables


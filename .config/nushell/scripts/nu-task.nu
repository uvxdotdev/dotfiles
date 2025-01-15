# Get config directory path with proper home directory expansion
def get-config-dir [] {
    $env.HOME | path join '.config/nu-task'
}

# Get CSV file path with proper home directory expansion
def get-csv-path [] {
    get-config-dir | path join 'tasks.csv'
}

# Check if directory exists, if not create it
def ensure-task-dir [] {
    let config_dir = (get-config-dir)
    if not ($config_dir | path exists) {
        mkdir $config_dir
    }
}

# Parse date from markdown task format
def parse-date [date_str: list<string>] {
    let date = ($date_str | get 0)
    try {
        $date | into datetime
    } catch {
        null
    }
}

# Get project from YAML frontmatter if it exists
def get-file-project [file_path: string] {
    let content = (open $file_path | str trim)
    if ($content | str starts-with "---") {
        let yaml_content = ($content 
            | split row "---" 
            | skip 1 
            | first 1 
            | to text 
            | from yaml)
        
        if ($yaml_content | get -i project | is-empty) {
            ""
        } else {
            $yaml_content.project | get 0 | get 0
        }
    } else {
        ""
    }
}

# Extract tasks from markdown file
def extract-tasks [file_path: string] {
    let content = (open $file_path | str trim)
    let project = (get-file-project $file_path)
    
    $content 
        | split row "\n"
        | enumerate
        | where { |item| ($item.item) =~ '\s*- \[ \]' }
        | each { |item|
            let line_number = ($item.index + 1)
            let line = $item.item
            # Find position of checkbox and extract from there
            let checkbox_pos = ($line | str index-of "- [ ]")
            let task = ($line | str substring ($checkbox_pos + 6)..)
            let parsed = ($task | parse "({due_date}) {task_name}")
            
            if ($parsed | is-empty) {
                return {
                    name: $task
                    creation_time: (date now)
                    due_date: null
                    file_path: $file_path
                    line_number: $line_number
                    project: $project
                }
            }
            
            return {
                name: ($parsed.task_name | get 0)
                creation_time: (date now)
                due_date: (parse-date $parsed.due_date)
                file_path: $file_path
                line_number: $line_number
                project: $project
            }
        }
}

# Add new task to CSV, preventing duplicates based on task name and file path
def add-task-to-csv [task: record] {
    let csv_path = (get-csv-path)
    
    # Read existing tasks or create empty list if no file exists
    let existing_tasks = if ($csv_path | path exists) {
        open $csv_path | to csv | from csv
    } else {
        []
    }
    
    # Check if task already exists (same name and file path)
    let is_duplicate = ($existing_tasks | any { |t| 
        $t."File Path" == $task.file_path and $t.Name == $task.name
    })
    
    # If it's a duplicate, update the line number but preserve other fields
    if $is_duplicate {
        # Update existing task's line number while preserving its status
        let updated_tasks = ($existing_tasks | each { |t|
            if $t."File Path" == $task.file_path and $t.Name == $task.name {
                # Update line number and project but keep other fields
                {
                    Name: $t.Name
                    "Creation Time": $t."Creation Time"
                    Project: $task.project
                    "Due Date": $t."Due Date"
                    "File Path": $t."File Path"
                    "Line Number": $task.line_number
                    Completed: $t.Completed
                }
            } else {
                $t
            }
        })
        $updated_tasks | to csv | save -f $csv_path
    } else {
        # Add new task with default Completed status
        let new_task = {
            Name: $task.name
            "Creation Time": $task.creation_time
            Project: $task.project
            "Due Date": $task.due_date
            "File Path": $task.file_path
            "Line Number": $task.line_number
            Completed: false
        }
        
        # Combine existing tasks with new task
        $existing_tasks | append $new_task 
        | to csv 
        | save -f $csv_path
    }
}

# Main task command that handles subcommands
def task [
    subcommand: string  # The subcommand to run (ls, tick, open, prune)
    ...args: any        # Additional arguments for the subcommand
] {
    match $subcommand {
        "ls" => { task-ls }
        "tick" => { 
            if ($args | length) == 0 {
                print "Usage: task tick <task_number> or task tick -a"
                return
            }
            if $args.0 == "all" {
                task-tick-all
            } else {
                task-tick $args.0
            }
        }
        "open" => { task-open $args.0 }
        "prune" => { task-prune }
        _ => {
            print $"Unknown subcommand: ($subcommand)"
            print "Available subcommands: ls, tick, open, prune"
            print "Usage for tick: task tick <task_number> or task tick -a"
        }
    }
}

# List all tasks
def task-ls [] {
    let csv_path = (get-csv-path)
    if not ($csv_path | path exists) {
        print "No tasks found. Add some tasks first!"
        return
    }
    
    let current_time = (date now)
    
    open $csv_path
    | to csv
    | from csv 
    | each { |task|
        let is_completed = ($task.Completed | str downcase | into string)
        let boolean_completed = if $is_completed == "true" { true } else { false }
        
        let creation_time = ($task."Creation Time" | into datetime)
        let age = ($creation_time | date humanize)
        
        let due_date = if ($task."Due Date" | is-empty) {
            "No due date"
        } else {
            let due = ($task."Due Date" | into datetime)
            $due | date humanize
        }
        
        # Calculate the name display value before creating the record
        let display_name = if $boolean_completed { 
            $'(ansi green)' + $task.Name
        } else { 
            $task.Name 
        }
        
        let display_task = {
            Name: $display_name
            Age: $age
            Project: $task.Project
            "Due Date": $due_date
        }
        
        $display_task
    }
}

# Open a specific task in Neovim
def task-open [task_number: int] {
    let csv_path = (get-csv-path)
    if not ($csv_path | path exists) {
        print "No tasks found. Add some tasks first!"
        return
    }
    
    let tasks = (open $csv_path | to csv | from csv)
    let task = ($tasks | get ($task_number - 1))
    
    if ($task | is-empty) {
        print "Task number $task_number not found."
        return
    }
    
    let file_path = $task."File Path" | to text
    let line_number = $task."Line Number" | to text
    
    if ($file_path == "" or $line_number == "") {
        print "Task does not have an associated file or line number."
        return
    }
    
    nu -c ('nvim ' + '+' + $line_number + ' ' + '"' + $file_path + '"')
}

# Toggle completion status of all tasks
def task-tick-all [] {
    let csv_path = (get-csv-path)
    if not ($csv_path | path exists) {
        print "No tasks found. Add some tasks first!"
        return
    }
    
    let tasks = (open $csv_path | to csv | from csv)
    
    # Get all incomplete tasks
    let incomplete_tasks = ($tasks | where Completed != "true" | length)
    
    # If there are any incomplete tasks, mark all as complete
    # Otherwise, mark all as incomplete
    let should_complete = $incomplete_tasks > 0
    
    # Update all tasks
    let updated_tasks = ($tasks | each { |task|
        # Update the task status
        {
            Name: $task.Name
            "Creation Time": $task."Creation Time"
            Project: $task.Project
            "Due Date": $task."Due Date"
            "File Path": $task."File Path"
            "Line Number": $task."Line Number"
            Completed: $should_complete
        }
    })
    
    # Save back to CSV
    $updated_tasks | to csv | save -f $csv_path
    
    # Update all markdown files
    $updated_tasks | each { |task|
        let file_path = $task."File Path"
        let line_number = $task."Line Number"
        
        if ($file_path | path exists) {
            let file_content = (open $file_path | lines)
            let line_index = ($line_number - 1)
            
            # Get the specific line and update the checkbox
            let updated_line = if $should_complete {
                # Replace unchecked box with checked box
                $file_content | get $line_index | str replace '- [ ]' '- [x]'
            } else {
                # Replace checked box with unchecked box
                $file_content | get $line_index | str replace '- [x]' '- [ ]'
            }
            
            # Update the specific line in the content
            let before_lines = ($file_content | first $line_index)
            let after_lines = ($file_content | skip ($line_index + 1))
            
            # Combine all parts and save back to file
            $before_lines | append [$updated_line] | append $after_lines | str join "\n"
            | save -f $file_path
        }
    }
    
    if $should_complete {
        print "Marked all tasks as complete"
    } else {
        print "Marked all tasks as incomplete"
    }
}

# Toggle the completed status of a specific task
def task-tick [task_number: int] {
    let csv_path = (get-csv-path)
    if not ($csv_path | path exists) {
        print "No tasks found. Add some tasks first!"
        return
    }
    
    let tasks = (open $csv_path | to csv | from csv)
    
    # Ensure the Completed field is treated as boolean
    let tasks = ($tasks | each { |task|
        let is_completed = ($task.Completed | str downcase | into string)
        let boolean_completed = if $is_completed == "true" { true } else { false }
        
        $task | update Completed { $boolean_completed }
    })
    
    let task = ($tasks | get ($task_number - 1))
    
    if ($task | is-empty) {
        print "Task number $task_number not found."
        return
    }
    
    let toggled_status = not ($task.Completed)
    
    # Update the task with the toggled Completed status
    let updated_task = {
        Name: $task.Name
        "Creation Time": $task."Creation Time"
        Project: $task.Project
        "Due Date": $task."Due Date"
        "File Path": $task."File Path"
        "Line Number": $task."Line Number"
        Completed: $toggled_status
    }
    
    # Replace the task in the list using enumerate and where
    let before_tasks = ($tasks | enumerate | where index < ($task_number - 1) | get item)
    let after_tasks = ($tasks | enumerate | where index > ($task_number - 1) | get item)
    
    # Combine the tasks lists with the updated task
    let updated_tasks = (
        $before_tasks | append [$updated_task] | append $after_tasks
    )
    
    # Save back to CSV
    $updated_tasks | to csv | save -f $csv_path
    
    # Update the markdown file
    let file_path = $task."File Path"
    let line_number = $task."Line Number"
    
    if ($file_path | path exists) {
        let file_content = (open $file_path | lines)
        let line_index = ($line_number - 1)
        
        # Get the specific line and update the checkbox
        let updated_line = if $toggled_status {
            # Replace unchecked box with checked box
            $file_content | get $line_index | str replace '- [ ]' '- [x]'
        } else {
            # Replace checked box with unchecked box
            $file_content | get $line_index | str replace '- [x]' '- [ ]'
        }
        
        # Update the specific line in the content
        let before_lines = ($file_content | first $line_index)
        let after_lines = ($file_content | skip ($line_index + 1))
        
        # Combine all parts and save back to file
        $before_lines | append [$updated_line] | append $after_lines | str join "\n"
        | save -f $file_path
    }
}

# Remove all completed tasks from the CSV file
def task-prune [] {
    let csv_path = (get-csv-path)
    if not ($csv_path | path exists) {
        print "No tasks found. Nothing to prune!"
        return
    }
    
    let tasks = (open $csv_path | to csv | from csv)
    
    # Count total and completed tasks before pruning
    let total_count = ($tasks | length)
    let completed_count = ($tasks | where Completed == "true" | length)
    
    if $completed_count == 0 {
        print "No completed tasks found to prune."
        return
    }
    
    # Keep only incomplete tasks
    let remaining_tasks = ($tasks | where Completed != "true")
    
    # Save the filtered tasks back to CSV
    $remaining_tasks | to csv | save -f $csv_path
}

# Main function to process markdown file
def process-markdown [file_path: string] {
    ensure-task-dir
    
    let tasks = (extract-tasks $file_path)
    
    $tasks | each { |task|
        add-task-to-csv $task
    }
    
    {
        file: $file_path
        tasks_processed: ($tasks | length)
    }
}

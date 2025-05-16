local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local previewers = require 'telescope.previewers'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

-- Cache for table details
local table_cache = {}

-- Function to fetch DynamoDB tables
local function fetch_tables()
  local result = vim.fn.system 'aws dynamodb list-tables --output json'
  local tables = vim.fn.json_decode(result).TableNames
  return tables or {}
end

-- Function to fetch table details (with caching)
local function fetch_table_details(table_name)
  if table_cache[table_name] then
    return table_cache[table_name]
  end

  local result = vim.fn.system('aws dynamodb describe-table --table-name ' .. table_name .. ' --output json')
  local details = vim.fn.json_decode(result)

  table_cache[table_name] = details
  return details
end

-- Function to fetch table rows
local function fetch_table_rows(table_name)
  local result = vim.fn.system('aws dynamodb scan --table-name ' .. table_name .. ' --output json')
  local rows = vim.fn.json_decode(result).Items
  return rows or {}
end

-- Function to create a previewer for table rows
local function create_row_previewer()
  return previewers.new_buffer_previewer {
    define_preview = function(self, entry, status)
      local row = entry.value
      if not row then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { 'No row selected' })
        return
      end

      local json_row = vim.fn.json_encode(row)
      if not json_row or json_row == '' then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { 'Failed to fetch row data' })
        return
      end

      -- Convert JSON to YAML using Nushell
      local yaml_row = vim.fn.system("echo '" .. json_row .. "' | nu -c 'from json | to yaml'")
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { 'Error converting row to YAML' })
        return
      end

      -- Ensure buffer content exists before setting the cursor
      local lines = vim.split(yaml_row, '\n')
      if #lines == 0 or lines[1] == '' then
        lines = { 'No data available' }
      end

      -- Clear buffer and set lines
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

      -- Safely set the cursor position after buffer population
      vim.schedule(function()
        if #lines > 0 then
          vim.api.nvim_win_set_cursor(self.state.winid, { 1, 0 })
        end
      end)
    end,
  }
end

-- Function to explore rows of a selected table
local function explore_rows(table_name)
  local rows = fetch_table_rows(table_name)
  if #rows == 0 then
    print('No rows found for table:', table_name)
    return
  end

  pickers
    .new({}, {
      prompt_title = 'Rows in Table: ' .. table_name,
      finder = finders.new_table {
        results = rows,
        entry_maker = function(row)
          return {
            value = row,
            display = function(entry)
              -- Display a concise representation of the row
              local row_summary = {}
              for key, value in pairs(entry.value) do
                table.insert(row_summary, key .. ': ' .. vim.inspect(value))
              end
              return table.concat(row_summary, ', ')
            end,
            ordinal = vim.inspect(row),
          }
        end,
      },
      sorter = require('telescope.config').values.generic_sorter(),
      previewer = create_row_previewer(),
      attach_mappings = function(_, map)
        actions.select_default:replace(function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          print('Selected row:', vim.inspect(selection.value))
        end)
        return true
      end,
    })
    :find()
end

-- Main function to explore DynamoDB tables
local function explore_dynamodb()
  local tables = fetch_tables()
  if #tables == 0 then
    print 'No DynamoDB tables found!'
    return
  end

  pickers
    .new({}, {
      prompt_title = 'Select DynamoDB Table',
      finder = finders.new_table(tables),
      sorter = require('telescope.config').values.generic_sorter(),
      previewer = previewers.new_buffer_previewer {
        define_preview = function(self, entry, status)
          local table_name = entry.value
          if not table_name then
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { 'No table selected' })
            return
          end

          local details = fetch_table_details(table_name)
          if not details then
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { 'Failed to fetch details for table: ' .. table_name })
            return
          end

          local lines = {
            'Table: ' .. table_name,
            'Items: ' .. (details.Table.ItemCount or 'Unknown'),
            'Status: ' .. (details.Table.TableStatus or 'Unknown'),
            'Size (bytes): ' .. (details.Table.TableSizeBytes or 'Unknown'),
            '',
            'Attributes:',
          }

          for _, attr in ipairs(details.Table.AttributeDefinitions or {}) do
            table.insert(lines, string.format('  %s (%s)', attr.AttributeName, attr.AttributeType))
          end

          table.insert(lines, '')
          table.insert(lines, 'Keys:')
          for _, key in ipairs(details.Table.KeySchema or {}) do
            table.insert(lines, string.format('  %s (%s)', key.AttributeName, key.KeyType))
          end

          -- Ensure buffer content exists before setting the cursor
          if #lines == 0 then
            lines = { 'No data available' }
          end

          -- Clear buffer and set lines
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

          -- Safely set the cursor position after buffer population
          vim.schedule(function()
            if #lines > 0 then
              vim.api.nvim_win_set_cursor(self.state.winid, { 1, 0 })
            end
          end)
        end,
      },
      attach_mappings = function(_, map)
        actions.select_default:replace(function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local table_name = selection[1]
          explore_rows(table_name)
        end)
        return true
      end,
    })
    :find()
end

-- Neovim Command
vim.api.nvim_create_user_command('ExploreDynamoDB', explore_dynamodb, {})

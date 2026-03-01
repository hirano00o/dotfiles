--- Thino-style quick post functionality for Neovim
--- Posts content to daily notes in Obsidian vault with timestamp
---
--- @description
--- This module provides a quick posting feature similar to Obsidian's Thino plugin.
--- It allows users to quickly add timestamped entries to their daily notes.
--- Supports multi-line input via floating window with Ctrl+Enter to submit.
---
--- @example
--- ```vim
--- :ThinoPost
--- " Opens a floating window for input
--- " Press <C-CR> or <C-s> to post, <Esc> or q to cancel
--- " Result in daily note:
--- " * 14:30:45 First line
--- "   Second line
--- "   Third line
--- ```
local M = {}

--- Time format for post timestamps (strftime format)
local TIME_FORMAT = "%H:%M:%S"

--- Obsidian format to Lua strftime format mapping
--- @type table<string, string>
local OBSIDIAN_TO_STRFTIME = {
  YYYY = "%%Y",
  YY = "%%y",
  MM = "%%m",
  DD = "%%d",
  HH = "%%H",
  mm = "%%M",
  ss = "%%S",
  ddd = "%%a",
  dddd = "%%A",
}

--- Convert Obsidian date format to Lua strftime format
---
--- Converts Obsidian-style date format strings to Lua's os.date strftime format.
--- Longer patterns are matched first to avoid partial replacements.
---
--- @param obsidian_format string Obsidian format string (e.g., "YYYY-MM-DD")
--- @return string strftime_format Lua strftime format (e.g., "%Y-%m-%d")
---
--- @example
--- ```lua
--- convert_to_strftime("YYYY-MM-DD") -- returns "%Y-%m-%d"
--- convert_to_strftime("YYYY年MM月DD日") -- returns "%Y年%m月%d日"
--- ```
local function convert_to_strftime(obsidian_format)
  local result = obsidian_format
  -- Sort by length descending to match longer patterns first (e.g., "dddd" before "ddd")
  local sorted_keys = {}
  for k in pairs(OBSIDIAN_TO_STRFTIME) do
    table.insert(sorted_keys, k)
  end
  table.sort(sorted_keys, function(a, b)
    return #a > #b
  end)

  for _, key in ipairs(sorted_keys) do
    result = result:gsub(key, OBSIDIAN_TO_STRFTIME[key])
  end
  -- Remove double percent signs added for gsub escaping
  result = result:gsub("%%%%", "%%")
  return result
end

--- Substitute parameterized template variables in text
---
--- Expands variables like {{date:YYYY}} and {{time:HH:mm}} using current datetime.
--- This handles Obsidian's parameterized template syntax that obsidian.nvim doesn't support.
---
--- @param text string The text containing template variables
--- @return string text The text with variables substituted
---
--- @example
--- ```lua
--- substitute_parameterized_vars("#{{date:YYYY}}年")
--- -- returns "#2026年" (if current year is 2026)
--- ```
local function substitute_parameterized_vars(text)
  -- Match {{date:FORMAT}} pattern
  text = text:gsub("{{date:([^}]+)}}", function(format)
    local strftime_format = convert_to_strftime(format)
    return os.date(strftime_format)
  end)

  -- Match {{time:FORMAT}} pattern
  text = text:gsub("{{time:([^}]+)}}", function(format)
    local strftime_format = convert_to_strftime(format)
    return os.date(strftime_format)
  end)

  return text
end

--- Process parameterized template variables in a file
---
--- Reads the file, substitutes parameterized variables like {{date:YYYY}},
--- and writes back if any changes were made.
---
--- @param file_path string Path to the file to process
local function process_template_vars(file_path)
  -- Read file content
  local file = io.open(file_path, "r")
  if not file then
    return
  end
  local content = file:read("*a")
  file:close()

  -- Check if there are any parameterized variables to process
  if not content:match("{{[^}]+:[^}]+}}") then
    return
  end

  -- Substitute variables
  local processed = substitute_parameterized_vars(content)

  -- Write back if changed
  if processed ~= content then
    file = io.open(file_path, "w")
    if file then
      file:write(processed)
      file:close()
    end
  end
end

--- Get obsidian.nvim client safely
---
--- Attempts to load obsidian.nvim and get the client instance.
--- Returns nil with error message if obsidian.nvim is not available.
---
--- @return table|nil client The obsidian client or nil if not available
--- @return string|nil error Error message if client is not available
local function get_obsidian_client()
  local ok, obsidian = pcall(require, "obsidian")
  if not ok then
    return nil, "obsidian.nvim is not installed"
  end

  local client_ok, client = pcall(obsidian.get_client)
  if not client_ok or not client then
    return nil, "obsidian.nvim client is not initialized"
  end

  return client, nil
end

--- Create a floating window for multi-line input
---
--- Creates a scratch buffer with a centered floating window for text input.
--- The window has markdown filetype for syntax highlighting.
---
--- @return number buf Buffer handle
--- @return number win Window handle
local function create_input_window()
  -- Create scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  -- Calculate window size and position (centered)
  local width = math.floor(vim.o.columns * 0.6)
  local height = 10
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Thino (<C-CR> or <C-s> to post) ",
    title_pos = "center",
  })

  -- Set window options
  vim.api.nvim_set_option_value("wrap", true, { win = win })
  vim.api.nvim_set_option_value("linebreak", true, { win = win })

  return buf, win
end

--- Format content lines for daily note
---
--- Formats multi-line content with timestamp on first line and indentation on subsequent lines.
---
--- @param lines string[] Content lines
--- @return string|nil formatted Formatted content for daily note, or nil if empty
---
--- @example
--- ```lua
--- format_content({"First line", "Second line"})
--- -- returns "* 14:30:45 First line\n  Second line\n"
--- ```
local function format_content(lines)
  -- Filter out empty lines
  local content_lines = vim.tbl_filter(function(line)
    return line ~= ""
  end, lines)

  if #content_lines == 0 then
    return nil
  end

  local time = os.date(TIME_FORMAT)
  local formatted_lines = {}

  for i, line in ipairs(content_lines) do
    if i == 1 then
      -- First line: timestamp + content
      table.insert(formatted_lines, string.format("* %s %s", time, line))
    else
      -- Subsequent lines: 2-space indent
      table.insert(formatted_lines, "  " .. line)
    end
  end

  return table.concat(formatted_lines, "\n") .. "\n"
end

--- Submit post to daily note
---
--- Gets content from buffer, formats it, and appends to daily note.
---
--- @param buf number Buffer handle
--- @param win number Window handle
--- @param client table Obsidian client
local function submit_post(buf, win, client)
  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local formatted = format_content(lines)

  -- Close window first
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  vim.cmd("stopinsert")

  -- Return if no content
  if not formatted then
    return
  end

  -- Get/create daily note with template processing
  local note = client:daily(0)
  local daily_path_str = tostring(note.path)

  -- Process parameterized template variables
  process_template_vars(daily_path_str)

  -- Append to daily note
  local file, open_err = io.open(daily_path_str, "a")
  if not file then
    vim.notify("Failed to open daily note: " .. (open_err or "unknown error"), vim.log.levels.ERROR)
    return
  end

  file:write(formatted)
  file:close()

  vim.notify("Posted to Thino", vim.log.levels.INFO)
end

--- Close input window without posting
---
--- @param win number Window handle
local function close_window(win)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  vim.cmd("stopinsert")
end

--- Post content to daily note with timestamp
---
--- Opens a floating window for multi-line input.
--- Press <C-CR> or <C-s> to submit, <Esc> or q to cancel.
--- If the daily note doesn't exist, it will be created using obsidian.nvim's
--- template processing, with additional expansion of parameterized variables.
---
--- @example
--- ```lua
--- require("config.thino").post()
--- -- Opens floating window
--- -- Type content, then press Ctrl+Enter to post
--- ```
function M.post()
  -- Get obsidian client
  local client, err = get_obsidian_client()
  if not client then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  -- Create input window
  local buf, win = create_input_window()

  -- Define submit function
  local function do_submit()
    submit_post(buf, win, client)
  end

  -- Define close function
  local function do_close()
    close_window(win)
  end

  -- Set up keymaps for this buffer
  local opts = { buffer = buf, noremap = true, silent = true }

  -- Submit: Ctrl+Enter or Ctrl+s (works in both normal and insert mode)
  vim.keymap.set({ "n", "i" }, "<C-CR>", do_submit, opts)
  vim.keymap.set({ "n", "i" }, "<C-s>", do_submit, opts)

  -- Cancel: Esc or q (normal mode only)
  vim.keymap.set("n", "<Esc>", do_close, opts)
  vim.keymap.set("n", "q", do_close, opts)

  -- Start in insert mode
  vim.cmd("startinsert")
end

-- Register user command
vim.api.nvim_create_user_command("ThinoPost", M.post, {
  desc = "Post to Thino (daily note)",
})

return M

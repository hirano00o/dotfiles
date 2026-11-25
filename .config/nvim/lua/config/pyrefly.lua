local M = {}

local MARKER_BEGIN = "-- BEGIN pyrefly_extra_paths (managed by :PyreflySourceRoot)"
local MARKER_END = "-- END pyrefly_extra_paths"

local function nvim_lua_path()
  return vim.fn.getcwd() .. "/.nvim.lua"
end

local function normalize(dir)
  local abs = vim.fn.fnamemodify(dir, ":p")
  return (abs:gsub("/$", ""))
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

local function write_file(path, content)
  local f = assert(io.open(path, "w"))
  f:write(content)
  f:close()
end

local function render_block(paths)
  local items = {}
  for _, p in ipairs(paths) do
    table.insert(items, string.format("  %q,", p))
  end
  return table.concat({
    MARKER_BEGIN,
    "vim.g.pyrefly_extra_paths = {",
    table.concat(items, "\n"),
    "}",
    MARKER_END,
  }, "\n")
end

-- .nvim.lua に手書きの他設定があっても壊さないよう、マーカー間だけを差し替える
local function persist(paths)
  local path = nvim_lua_path()
  local content = read_file(path) or ""
  local block = render_block(paths)
  local pattern = vim.pesc(MARKER_BEGIN) .. ".-" .. vim.pesc(MARKER_END)

  if content:find(pattern) then
    content = content:gsub(pattern, (block:gsub("%%", "%%%%")))
  else
    if content ~= "" and not content:match("\n$") then
      content = content .. "\n"
    end
    content = content .. block .. "\n"
  end

  write_file(path, content)
end

-- 起動中の pyrefly クライアントに再起動なしで反映する
local function apply_live()
  for _, client in ipairs(vim.lsp.get_clients({ name = "pyrefly" })) do
    client.settings.python = client.settings.python or {}
    client.settings.python.pyrefly = client.settings.python.pyrefly or {}
    client.settings.python.pyrefly.extraPaths = vim.g.pyrefly_extra_paths or {}
    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
  end
end

function M.list()
  return vim.g.pyrefly_extra_paths or {}
end

function M.add(dirs)
  if #dirs == 0 then
    local current = M.list()
    if #current == 0 then
      vim.notify("pyrefly extraPaths: (empty)", vim.log.levels.INFO)
    else
      vim.notify("pyrefly extraPaths:\n" .. table.concat(current, "\n"), vim.log.levels.INFO)
    end
    return
  end

  local paths = vim.deepcopy(M.list())
  for _, dir in ipairs(dirs) do
    local abs = normalize(dir)
    if not vim.list_contains(paths, abs) then
      table.insert(paths, abs)
    end
  end

  vim.g.pyrefly_extra_paths = paths
  persist(paths)
  apply_live()
  vim.notify("pyrefly extraPaths updated:\n" .. table.concat(paths, "\n"), vim.log.levels.INFO)
end

function M.clear()
  vim.g.pyrefly_extra_paths = {}
  persist({})
  apply_live()
  vim.notify("pyrefly extraPaths cleared", vim.log.levels.INFO)
end

-- Telescope でディレクトリだけを一覧してポップアップ選択する（<Tab> で複数選択可）
function M.pick()
  local ok_builtin, telescope_builtin = pcall(require, "telescope.builtin")
  if not ok_builtin then
    vim.notify("telescope.nvim が必要です", vim.log.levels.ERROR)
    return
  end

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local find_command = vim.fn.executable("fd") == 1
      and { "fd", "--type", "d", "--hidden", "--exclude", ".git" }
      or { "find", ".", "-type", "d", "-not", "-path", "*/.git*" }

  telescope_builtin.find_files({
    prompt_title = "Pyrefly Source Root (<Tab>で複数選択)",
    find_command = find_command,
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()
        actions.close(prompt_bufnr)

        local dirs = {}
        if #selections > 0 then
          for _, entry in ipairs(selections) do
            table.insert(dirs, entry[1] or entry.value)
          end
        else
          local entry = action_state.get_selected_entry()
          if entry then
            table.insert(dirs, entry[1] or entry.value)
          end
        end

        if #dirs > 0 then
          M.add(dirs)
        end
      end)
      return true
    end,
  })
end

return M

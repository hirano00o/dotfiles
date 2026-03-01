-- venv環境変数 -> プロジェクトルートのvenv -> グローバル
local function get_python_path(workspace)
  local venv = vim.env.VIRTUAL_ENV
  if venv then
    return venv .. "/bin/python"
  end

  if workspace then
    local venv_paths = { ".venv", "venv" }
    for _, path in ipairs(venv_paths) do
      local venv_python = workspace .. "/" .. path .. "/bin/python"
      if vim.fn.executable(venv_python) == 1 then
        return venv_python
      end
    end
  end

  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

local function get_venv_executable(workspace, executable_name)
  local venv = vim.env.VIRTUAL_ENV
  if venv then
    local venv_exe = venv .. "/bin/" .. executable_name
    if vim.fn.executable(venv_exe) == 1 then
      return venv_exe
    end
  end

  if workspace then
    local venv_paths = { ".venv", "venv" }
    for _, path in ipairs(venv_paths) do
      local venv_exe = workspace .. "/" .. path .. "/bin/" .. executable_name
      if vim.fn.executable(venv_exe) == 1 then
        return venv_exe
      end
    end
  end

  return executable_name
end

return {
  on_new_config = function(config, root_dir)
    config.cmd = { get_venv_executable(root_dir, "pyright-langserver"), "--stdio" }
    config.settings.python.pythonPath = get_python_path(root_dir)
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
    pyright = {
      -- ruffを利用する
      disableOrganizeImports = true,
    },
  },
}

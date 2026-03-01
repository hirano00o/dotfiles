local function get_venv_executable_only(workspace, executable_name)
  local venv = os.getenv("VIRTUAL_ENV")
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

  -- venvにない場合はnilを返す
  return nil
end

return {
  on_new_config = function(config, root_dir)
    -- venv内のruffを優先、ただしvenvにruffがなければ実行しない
    config.cmd = { get_venv_executable_only(root_dir, "ruff"), "server", "--preview" }
  end,
  init_options = {
    settings = {
      args = {},
    },
  },
}

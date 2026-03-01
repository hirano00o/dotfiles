local function ime_control_macos(action)
  if action == "off" then
    return vim.fn.system("osascript -e 'tell application \"System Events\" to key code 102'")
  elseif action == "on" then
    return vim.fn.system("osascript -e 'tell application \"System Events\" to key code 104'")
  end
  return nil
end

local function ime_control_linux(action)
  if vim.fn.executable("fcitx-remote") == 1 then
    if action == "off" then
      return vim.fn.system("fcitx-remote -c")
    elseif action == "on" then
      return vim.fn.system("fcitx-remote -o")
    end
  elseif vim.fn.executable("ibus") == 1 then
    if action == "off" then
      return vim.fn.system("ibus engine 'xkb:us::eng'")
    elseif action == "on" then
      return vim.fn.system("ibus engine 'mozc-jp'")
    end
  end
  return nil
end

local uname = vim.uv.os_uname().sysname:lower()
local group = vim.api.nvim_create_augroup("ime_control", {})
if uname == "darwin" then
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      vim.schedule(function()
        ime_control_macos("off")
      end)
    end,
  })
elseif uname == "linux" then
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      vim.schedule(function()
        ime_control_linux("off")
      end)
    end,
  })
end

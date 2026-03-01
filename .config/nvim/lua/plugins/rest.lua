return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  config = function()
    require("kulala").setup({
      default_view = "body",
      default_env = "dev",
      debug = false,
    })

    local function is_binary_content(content_type)
      if not content_type then return false end

      local binary_types = {
        "application/octet%-stream",
        "application/pdf",
        "application/zip",
        "application/x%-zip",
        "application/vnd%.ms%-excel",
        "application/vnd%.openxmlformats%-officedocument",
        "application/vnd%.ms%-word",
        "application/vnd%.ms%-powerpoint",
        "application/msword",
        "application/x%-msdownload",
        "image/",
        "video/",
        "audio/",
      }

      for _, pattern in ipairs(binary_types) do
        if content_type:match(pattern) then
          return true
        end
      end
      return false
    end

    local function extract_filename_from_header(disposition)
      if not disposition then return nil end

      local filename = disposition:match("filename%*=UTF%-8''([^;]+)")
      if filename then
        filename = filename:gsub("%%(%x%x)", function(hex)
          return string.char(tonumber(hex, 16))
        end)
        return filename
      end

      filename = disposition:match('filename="([^"]+)"')
      if filename then return filename end

      filename = disposition:match("filename=([^;]+)")
      if filename then return filename:gsub("^%s*(.-)%s*$", "%1") end

      return nil
    end

    local function guess_extension_from_content_type(content_type)
      if not content_type then return "bin" end

      local extensions = {
        ["application/pdf"] = "pdf",
        ["application/zip"] = "zip",
        ["application/vnd.ms-excel"] = "xls",
        ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"] = "xlsx",
        ["application/vnd.ms-excel.sheet.macroenabled.12"] = "xlsm",
        ["application/vnd.ms-word"] = "doc",
        ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"] = "docx",
        ["application/vnd.ms-powerpoint"] = "ppt",
        ["application/vnd.openxmlformats-officedocument.presentationml.presentation"] = "pptx",
        ["image/jpeg"] = "jpg",
        ["image/png"] = "png",
        ["image/gif"] = "gif",
        ["image/webp"] = "webp",
      }

      return extensions[content_type:lower()] or "bin"
    end

    local function auto_save_binary()
      local cache_dir = vim.fn.stdpath('cache') .. '/kulala'
      local headers_file = cache_dir .. '/headers.txt'
      local body_file = cache_dir .. '/body.txt'

      if vim.fn.filereadable(headers_file) == 0 or vim.fn.filereadable(body_file) == 0 then
        return
      end

      local all_lines = vim.fn.readfile(headers_file)
      local headers = {}
      local in_http_headers = false

      for _, line in ipairs(all_lines) do
        if line:match("^HTTP/%d%.%d%s+%d+") then
          in_http_headers = true
        elseif in_http_headers then
          if line == "" then break end

          local key, value = line:match("^([^:]+):%s*(.+)$")
          if key and value then
            headers[key:lower()] = value
          end
        end
      end

      local content_type = headers["content-type"]
      if not content_type or not is_binary_content(content_type) then
        return
      end

      local filename = extract_filename_from_header(headers["content-disposition"])

      if not filename then
        local timestamp = os.date("%Y%m%d_%H%M%S")
        local ext = guess_extension_from_content_type(content_type)
        filename = string.format("download_%s.%s", timestamp, ext)
      end

      local download_dir = vim.fn.expand("~/Downloads")
      if vim.fn.isdirectory(download_dir) == 0 then
        vim.fn.mkdir(download_dir, "p")
      end

      local save_path = download_dir .. "/" .. filename
      local counter = 1
      local base_name = filename:match("^(.+)%.[^.]+$") or filename
      local extension = filename:match("%.([^.]+)$") or ""

      while vim.fn.filereadable(save_path) == 1 do
        if extension ~= "" then
          filename = string.format("%s_%d.%s", base_name, counter, extension)
        else
          filename = string.format("%s_%d", base_name, counter)
        end
        save_path = download_dir .. "/" .. filename
        counter = counter + 1
      end

      local cmd = string.format('cp %s %s',
        vim.fn.shellescape(body_file),
        vim.fn.shellescape(save_path)
      )

      local result = vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        vim.notify(string.format('✓ ファイルを保存しました: %s', save_path), vim.log.levels.INFO)
      else
        vim.notify('ファイルの保存に失敗しました', vim.log.levels.ERROR)
      end
    end

    vim.api.nvim_create_user_command('KulalaSaveBinary', auto_save_binary, { desc = 'Save binary response to file' })

    local watch_handle = nil
    local function start_watching()
      if watch_handle then return end

      local body_file = vim.fn.stdpath('cache') .. '/kulala/body.txt'
      vim.uv = vim.uv or vim.loop
      watch_handle = vim.uv.new_fs_event()

      if watch_handle then
        watch_handle:start(body_file, {}, function(err)
          if not err then
            vim.schedule(function()
              vim.defer_fn(auto_save_binary, 500)
            end)
          end
        end)
      end
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'http', 'rest' },
      callback = function(ev)
        vim.keymap.set("n", "<SC-r>", function()
          require('kulala').run()
          vim.defer_fn(function()
            vim.cmd('KulalaSaveBinary')
          end, 1000)
        end, { buffer = ev.buf, desc = "Run REST-http in .http file" })

        start_watching()
      end
    })
  end
}

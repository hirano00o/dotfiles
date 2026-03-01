--- OpenAPI $ref ナビゲーション機能
---
--- YAMLファイル内の$ref参照をナビゲートする。
--- yamllsのdocumentLink機能が外部ファイル参照に対応していないため、
--- カスタム実装で対応。
---
--- 機能:
--- - gf: $ref参照先へジャンプ（外部ファイル/ファイル内両対応）
--- - gr: カーソル位置のスキーマを参照している$refを検索
--- - Ctrl-t: ジャンプ元に戻る
---
--- @example
--- ```yaml
--- # 外部ファイル参照
--- $ref: "./schema.yaml#/components/schemas/User"
--- # ファイル内参照
--- $ref: "#/components/schemas/User"
--- ```

--- タグスタックに現在位置を記録
---
--- ジャンプ前に呼び出すことで、Ctrl-tで戻れるようになる。
---
--- @param tagname string タグ名（$refパス）
--- @return nil
local function push_tagstack(tagname)
  local pos = vim.api.nvim_win_get_cursor(0)
  local current_buf = vim.api.nvim_get_current_buf()
  local item = {
    tagname = tagname,
    from = { current_buf, pos[1], pos[2] + 1, 0 },
  }
  vim.fn.settagstack(vim.fn.win_getid(), { items = { item } }, "t")
end

--- ファイル内参照（#/path/to/key）の該当行にジャンプ
---
--- フラグメントパスを解析し、最後の要素（スキーマ名等）を
--- 同一ファイル内で検索してジャンプする。
---
--- @param fragment string フラグメントパス（例: /components/schemas/CustomPreset）
--- @param skip_tagstack boolean? タグスタックへのプッシュをスキップするか（外部ファイルジャンプ後に使用）
--- @return nil
local function goto_fragment(fragment, skip_tagstack)
  -- フラグメントをパス要素に分割
  local parts = {}
  for part in fragment:gmatch("[^/]+") do
    table.insert(parts, part)
  end

  if #parts == 0 then
    return
  end

  -- 最後の要素（スキーマ名等）を検索
  local target = parts[#parts]
  local pattern = "^%s*" .. vim.pesc(target) .. ":"

  for lnum = 1, vim.api.nvim_buf_line_count(0) do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    if line:match(pattern) then
      if not skip_tagstack then
        push_tagstack("#" .. fragment)
      end
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      return
    end
  end

  vim.notify("Definition not found: " .. target, vim.log.levels.WARN)
end

--- $ref参照先にジャンプする
---
--- 現在行から$refパスを抽出し、参照先にジャンプする。
--- - 外部ファイル参照: ファイルを開く
--- - ファイル内参照: 同一ファイル内の該当行にジャンプ
--- タグスタックに記録するため、Ctrl-tで戻れる。
---
--- @return nil
local function goto_ref()
  local line = vim.api.nvim_get_current_line()

  -- $ref: "path#/fragment" または $ref: 'path#/fragment' を抽出
  local ref_path = line:match('%$ref:%s*["\']([^"\']+)["\']')
  if not ref_path then
    -- 通常のgfにフォールバック
    return vim.cmd("normal! gf")
  end

  -- ファイル部分とフラグメント部分を分離
  local file_path, fragment = ref_path:match("^([^#]*)#(.*)$")

  if not fragment then
    -- フラグメントがない場合（ファイルのみ）
    file_path = ref_path
    fragment = nil
  end

  -- ファイル内参照の場合（#で始まる、またはファイル部分が空）
  if file_path == "" or file_path == nil then
    if fragment and fragment ~= "" then
      goto_fragment(fragment)
    end
    return
  end

  -- 外部ファイル参照の場合
  local current_dir = vim.fn.expand("%:p:h")
  local full_path = current_dir .. "/" .. file_path

  if vim.fn.filereadable(full_path) == 1 then
    push_tagstack(ref_path)
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))

    -- ファイルを開いた後、フラグメントがあればその位置にジャンプ
    if fragment and fragment ~= "" then
      -- 少し遅延してからフラグメントにジャンプ（バッファ読み込み完了後）
      -- skip_tagstack=true: 既にgoto_ref内でタグスタックにプッシュ済み
      vim.schedule(function()
        goto_fragment(fragment, true)
      end)
    end
  else
    vim.notify("File not found: " .. full_path, vim.log.levels.WARN)
  end
end

--- カーソル位置のYAMLパスを取得
---
--- インデントを解析して、現在のキーの完全なYAMLパスを構築する。
---
--- @return string YAMLパス（例: /components/schemas/CustomPreset）
---
--- @example
--- ```yaml
--- components:
---   schemas:
---     CustomPreset:  # カーソルがここにある場合
---       type: object
--- ```
--- → "/components/schemas/CustomPreset"
local function get_yaml_path_at_cursor()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_indent = #(vim.api.nvim_get_current_line():match("^%s*") or "")
  local path = {}

  -- 現在行のキー名を取得
  local current_key = vim.api.nvim_get_current_line():match("^%s*([%w_%-]+):")
  if current_key then
    table.insert(path, 1, current_key)
  end

  -- 上方向に親キーを探索
  for lnum = current_line - 1, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    local indent = #(line:match("^%s*") or "")
    local key = line:match("^%s*([%w_%-]+):")

    if key and indent < current_indent then
      table.insert(path, 1, key)
      current_indent = indent
    end

    if indent == 0 and key then
      break
    end
  end

  return "/" .. table.concat(path, "/")
end

--- カーソル位置のスキーマを参照している$refを検索
---
--- カーソル位置のYAMLパスを取得し、そのパスを含む$refを
--- プロジェクト全体から検索してquickfixリストに表示する。
--- ripgrepを直接呼び出して確実に検索する。
---
--- @return nil
---
--- @example
--- CustomPreset上でgrを押すと、以下のような$refを検索:
--- - $ref: "#/components/schemas/CustomPreset"
--- - $ref: "./schema.yaml#/components/schemas/CustomPreset"
--- - $ref: "../schema.yaml#/components/schemas/CustomPreset"
local function find_refs()
  local yaml_path = get_yaml_path_at_cursor()
  if yaml_path == "/" then
    vim.notify("No YAML key found at cursor", vim.log.levels.WARN)
    return
  end

  local search_dir = vim.fn.getcwd()

  -- ripgrepで検索（--vimgrep形式で出力）
  -- パターン: $ref.*#/path/to/schema["']
  local pattern = "\\$ref.*#" .. yaml_path .. "[\"']"
  local cmd = { "rg", "--vimgrep", "-e", pattern, search_dir }
  local output = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 or #output == 0 then
    vim.notify("No references found for: " .. yaml_path, vim.log.levels.INFO)
    return
  end

  -- 結果をquickfixリストに追加
  local qflist = {}
  for _, line in ipairs(output) do
    local filename, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
    if filename then
      table.insert(qflist, {
        filename = filename,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = text,
      })
    end
  end

  if #qflist > 0 then
    vim.fn.setqflist(qflist, "r")
    vim.cmd("copen")
  else
    vim.notify("No references found for: " .. yaml_path, vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<C-]>", goto_ref, { buffer = true, desc = "Go to $ref" })
vim.keymap.set("n", "gr", find_refs, { buffer = true, desc = "Find $ref references" })

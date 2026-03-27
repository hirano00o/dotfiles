return {
  "folke/snacks.nvim",
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = false,
        float = true,
      },
      convert = {
        mermaid = function()
          local theme = vim.o.background == "light" and "neutral" or "dark"
          return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}" }
        end,
      },
      formats = {
        "png", "jpg", "jpeg", "gif", "webp", "avif",
        "bmp", "tiff", "heic", "ico", "icns", "svg",
        -- 動画（サムネイル表示）
        "mp4", "mov", "webm",
        -- ドキュメント
        "pdf",
      },
    },
  },
}

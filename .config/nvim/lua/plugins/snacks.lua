return {
  "folke/snacks.nvim",
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        float = true,
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

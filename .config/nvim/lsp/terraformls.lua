return {
  root_markers = { ".terraform", "terraform.tfvars", ".git" },
  settings = {
    terraformls = {
      indexing = {
        ignoreDirectoryNames = { ".git", "node_modules" },
      },
    },
  },
}

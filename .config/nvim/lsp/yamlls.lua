return {
  settings = {
    yaml = {
      schemas = require('schemastore').yaml.schemas(),
      validate = { enable = true },
    },
  },
}

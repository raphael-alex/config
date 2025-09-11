local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    plugins = { -- 我认为这才是让我成功的突破点
      {
        name = "@vue/typescript-plugin",
        location = "/home/rah/.nvm/versions/node/v24.7.0/lib/node_modules/@vue/language-server",
        languages = { "vue" },
      },
    },
  },
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
})

lspconfig.volar.setup({})

-- 如果你只想使用服务器的默认配置，就把它们放在一个表格里
local servers = { "html", "cssls", "eslint" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

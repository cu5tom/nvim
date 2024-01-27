-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

local lsp_conflicts, _ = pcall(vim.api.nvim_get_autocmds, { group = "LspAttach_conficts" })
if not lsp_conflicts then
  vim.api.nvim_create_augroup("LspAttach_conficts", {})
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = "LspAttach_conficts",
  desc = "Prevent TSServer and Volar competing",
  callback = function(args)
    if not args.data and args.data.client_id then
      return
    end

    local active_clients = vim.lsp.get_active_clients()
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.name == "volar" then
      for _, client_ in pairs(active_clients) do
        if client_.name == "tsserver" then
          client_.stop()
        end
      end
    elseif client.name == "tsserver" then
      for _, client_ in pairs(active_clients) do
        if client_.name == "volar" then
          client_.stop()
        end
      end
    end
  end,
})

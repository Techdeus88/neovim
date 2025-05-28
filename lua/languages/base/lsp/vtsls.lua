--Start-of-file--
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")
local lsp_dependencies = {
    "vtsls",
}

local ft = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "javascript.jsx",
    "typescript.tsx",
}
local lsp_config = nil

local root_markers = {
    ".git",
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "vtsls",
        cmd = {},
        filetypes = Global.file_types.vtsls,
        settings = {
            -- handlers = {
            --     source_definition = function(err, locations) end,
            --     file_references = function(err, locations) end,
            --     code_action = function(err, actions) end,
            -- },
            -- automatically trigger renaming of extracted symbol
            refactor_auto_rename = true,
            -- refactor_move_to_file = {
            --     -- If dressing.nvim is installed, telescope will be used for selection prompt. Use this to customize
            --     -- the opts for telescope picker.
            --     telescope_opts = function(items, default) end,
            -- },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
            },
            typescript = {
                inlayHints = {
                    parameterNames = { enabled = "literals" },
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            }
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            setup_diagnostics.omni_tags(client, bufnr)
            setup_diagnostics.navic(client, bufnr)

            -- if client and client.name == "vtsls" then
            --     -- Ensure buffer has proper sync
            --     vim.defer_fn(function()
            --         -- Force document sync by making a trivial modification
            --         if vim.api.nvim_buf_is_valid(bufnr) then
            --             local modified = vim.bo[bufnr].modified
            --             vim.api.nvim_buf_set_option(bufnr, 'modified', true)
            --             vim.api.nvim_buf_set_option(bufnr, 'modified', modified)
            --         end
            --     end, 100)
            -- end
            -- vim.api.nvim_buf_create_user_command(bufnr, "TypescriptOrganizeImports", function()
            --     vim.lsp.buf.execute_command({
            --         command = "_typescript.organizeImports",
            --         arguments = { vim.api.nvim_buf_get_name(bufnr) },
            --     })
            -- end, { desc = "Organize Imports" })
        end,
        capabilities = setup_diagnostics.get_capabilities(),
    }
end)


return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

--End-of-file--

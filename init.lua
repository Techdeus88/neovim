--Start-of-file
--[[
1. Organize the configuration into distinct phases:
    A.  Core settings (options).
    B.  Language and filetype settings.
    C.  Plugin manager initialization.
          -   Use mini.deps for plugin management:
          -   Register and configure plugins using mini.deps.
    D.  Plugin configurations.
    E.  Color scheme.
    F.  Custom commands.
    G.  Keymaps.
    H.  Custom utilities.
2. Ensure modularity:
    A.  Each configuration aspect (e.g., options, plugins, commands) is handled in its own module.
    B.  Ensure that the configuration is organized in a way that is easy to understand and maintain.
    C.  Use functions and modules to encapsulate and abstract configuration logic.
    D.  Enforce a consistent naming convention for functions and modules.
    E.  Use comments to explain the purpose of each configuration aspect.
    F.  Deploy a consistent style for configuration files, function and variable names, and comments.
3. Start your engines below by pressing the button that says core:
    A. 1
    B. 2
    C. 3
--]]
_G.DEUS_NVIM_VERSION = vim.version()
if _G.DEUS_NVIM_VERSION.major == 0 and _G.DEUS_NVIM_VERSION.minor < 11 then
  print "TECHDEUS IDE required Neovim >= 0.11.0"
else
  pcall(require, "core")
end

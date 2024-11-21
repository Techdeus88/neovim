---@type fun(): DeusConfig
local module = function()
  ---@return DeusConfig
  return {
    add = {
      source = "", -- Required
      depends = {},
      post_checkout = nil,
      post_install = nil,
      monitor = nil,
    },
    require = nil,             -- Optional
    load = "now",              -- now | later
    s_load = "later",          -- now | later
    setup_param = "setup",     -- *setup,init,set,<custom>
    setup_type = "full-setup", -- invoke-setup | *full-setup
    pre_setup = function() end,
    setup_opts = function() end,
    post_setup = function() end,
  }
end
---@alias DeusConfig { add: AddConfig, require: RequireString, load: LoadEvent, s_load: LoadEvent, setup_opts: SetupOpts, post_setup: PostSetup } -- Ensure this is defined before usage
---@alias DeusConfigWrapper fun(): DeusConfig
---@alias Module DeusConfigWrapper

---@alias SourceString string The source of this dependency (where to download)
---@alias DependsList string[] The list of dependencies to be loaded prior to the source
---@alias PostCheckout any The command to pass to MiniDeps after every checkout
---@alias PostInstall any The command to pass to MiniDeps after the initial install
---@alias AddConfig { source: SourceString, depends: DependsList, post_checkout: PostCheckout, post_install: PostInstall } -- Ensure this is defined before usage
---@alias RequireString string -- Ensure this is defined before usage
---@alias LoadEvent "now" | "later"
---@alias SetupOpts fun(): nil -- Ensure this is defined before usage
---@alias PostSetup fun(): nil -- Ensure this is defined before usage

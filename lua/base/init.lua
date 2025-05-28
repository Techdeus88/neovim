local B = {}

local EVENTS = {
  START = "TechdeusStart",
  READY = "TechdeusReady"
}

local BASE_MODULES = {
  start = {
    { name = "techdeus", async = false, defer_time = nil },
    { name = 'options',  async = false, defer_time = nil },
    { name = 'commands', async = false, defer_time = nil },
  },
  ready = {
    { name = 'metrics',  async = false, defer_time = nil },
    { name = 'mappings', async = false, defer_time = nil },
  }
}

local function validate_event(event_name)
  return event_name == "TechdeusStart" or event_name == "TechdeusReady"
end

local function log_module_load(module_name, phase)
  Debug.log(string.format("Loading module '%s' in %s phase", module_name, phase), "modules", "INFO")
end


local function create_module_autocmd(module, phase)
  local event = phase == "start" and EVENTS.START or EVENTS.READY
  if not validate_event(event) then
    vim.notify(string.format("Invalid event: %s", event), vim.log.levels.ERROR)
    return
  end

  return vim.api.nvim_create_autocmd('User', {
    pattern = event,
    group = vim.api.nvim_create_augroup('Techdeus IDE_' .. module.name, { clear = true }),
    once = true,
    callback = function()
      local base_configs = require("configs.base")
      if not base_configs then
        vim.notify("Failed to load base configs", vim.log.levels.ERROR)
        return
      end

      local ok, err = pcall(function()
        base_configs.load_file_module(module)
        log_module_load(module.name, phase)
      end)

      if not ok then
        vim.notify(string.format("Failed to load module %s: %s", module.name, err), vim.log.levels.ERROR)
      end
    end,
  })
end

function B.init()
  -- Load start phase modules
  for _, module in ipairs(BASE_MODULES.start) do
    create_module_autocmd(module, "start")
  end

  -- Load ready phase modules
  for _, module in ipairs(BASE_MODULES.ready) do
    create_module_autocmd(module, "ready")
  end

  -- Setup debug logging
  vim.api.nvim_create_autocmd('User', {
    pattern = EVENTS.READY,
    group = vim.api.nvim_create_augroup('Techdeus IDE_Debug', { clear = true }),
    once = true,
    callback = function()
      vim.defer_fn(Debug.debug_events, 30000)
      Debug.log("Debug events initialized", "events", "INFO")
    end,
  })
end

return { init = B.init }

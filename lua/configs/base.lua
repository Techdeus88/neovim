--Start-of-file--
local B = {}

-- Load lua/base/config/*
---@param name 'techdeus' | 'commands' | 'options' | 'mappings' | 'languages'
function B.load_file_module(module)
  local mod = 'base.' .. module.name
  Debug.log('Loading: ' .. module.name, "modules")
  if module.is_async then
    local ok, err = pcall(vim.schedule, function()
      vim.defer_fn(function()
        local ok, err = pcall(require, mod)
        if not ok then
          if err:find('module ' .. mod .. ' not found') then
            return false
          end
          Debug.log('Error loading ' .. mod .. ': ' .. err, "modules")
        end
        Debug.log('Loaded ' .. mod, "modules")
        return true
      end, module.defer_time)
    end)
    if not ok then
      Debug.log('Error loading ' .. mod .. ': ' .. err, "modules")
      return false
    end
    return true
  end
  local ok, err = pcall(require, mod)
  if not ok then
    Debug.log('Error loading ' .. mod .. ': ' .. err, "modules")
    if err:find('module ' .. mod .. ' not found') then
      return false
    end
  end
  if ok then
    Debug.log('Loaded ' .. mod, "modules")
    return true
  end
end

function B.load_module(name)
  local _, modules = pcall(require, 'base')
  local module = modules[name]
  if type(module) == 'function' then
    local ok, err = pcall(module)
    if not ok then
      if err:find('module ' .. err .. ' not found') then
        return
      end
      vim.notify('Error loading ' .. module .. ': ' .. module, vim.log.levels.ERROR)
    end
    if ok then
      Debug.log('Loaded ' .. name, "modules")
    end
  end
end

function B.load_color_scheme(colorscheme)
  if not pcall(vim.cmd.colorscheme, colorscheme) then
    Debug.log('Colorscheme ' .. colorscheme .. ' not found!', "modules")
  end
end

return B
--End-of-file--
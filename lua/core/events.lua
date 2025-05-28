--Start-of-file--
local event_manager = {
    handlers = {},
    emitted = {},
}

function event_manager:register_handler(event_name, event_data)
    if not self:validate_event_data(event_data) then
        vim.notify(string.format('Invalid event data for %s', event_name), 
            vim.log.levels.ERROR)
        return
    end
    if not self.handlers[event_name] then
        self.handlers[event_name] = {}
    end
    -- Store the complete event data structure
    table.insert(self.handlers[event_name], {
        event_data = event_data,
        module_id = event_data.module_id
    })

    -- If event was already emitted, trigger handler immediately
    if self.emitted[event_name] then
        event_data.handler(self.emitted[event_name])
    end
end

function event_manager:validate_event_data(event_data)
    if not event_data then return false end
    if not event_data.handler or type(event_data.handler) ~= 'function' then
        return false
    end
    return true
end


function event_manager:get_handlers(event)
    return self.handlers[event]
end

function event_manager:emit_event(event_name, data, is_urgent)
    self.emitted[event_name] = data

    -- Trigger all registered handlers correctly
    if self.handlers[event_name] then
        for _, handler_entry in ipairs(self.handlers[event_name]) do
            if handler_entry.event_data and handler_entry.event_data.handler then
                handler_entry.event_data.handler(data)
            end
        end
    end

    local function trigger()
        local is_user_event = string.match(event_name, '^User ') ~= nil
        if is_user_event then
            local event = event_name:gsub('^User ', '')
            vim.api.nvim_exec_autocmds('User', {
                pattern = event,
                data = data,
                modeline = false
            })
        else
            vim.api.nvim_exec_autocmds(event_name, {
                data = data,
                modeline = false
            })
        end
    end

    if is_urgent then
        trigger()
    else
        vim.schedule(trigger)
    end
end

function event_manager:is_emitted(event_name)
    return self.emitted[event_name] ~= nil
end

function event_manager:get_event_status(event_name)
    return {
        emitted = self:is_emitted(event_name),
        handler_count = self.handlers[event_name] and #self.handlers[event_name] or 0
    }
end

function event_manager:setup_event_manager()
    return event_manager
end

local setup_event_manager = function()
    local manager = event_manager:setup_event_manager()
    _G.Events = manager
end

function init()
    setup_event_manager()
end

return { init = init }

--End-of-file--
-- Trigger an event and execute its handlers
-- function module_manager:trigger_event(event, args)
--   local event_callbacks = self:get_handlers(event)
--   if event_callbacks then
--     for _, entry in ipairs(event_callbacks) do
--       local module = self.modules[entry.module_id]
--       if module and module.added then
--         if event == 'FileType' and args then
--           local buf_ft = vim.api.nvim_buf_get_option(args.buf, 'filetype')
--           if buf_ft == entry.event_data.ft then
--             entry.event_data.handler(args)
--           end
--         else
--           entry.event_data.handler(args)
--         end
--       end
--     end
--   end
-- end

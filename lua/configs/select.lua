local S = {}
local funcs = require("core.funcs")
-- Deep merge function that preserves structure and handles nested tables
function S.deep_merge(default_tbl, override_tbl)
    local result = vim.deepcopy(default_tbl)
    
    -- Function to recursively merge tables
    local function merge(target, source)
        for k, v in pairs(source) do
            if type(v) == "table" and type(target[k]) == "table" then
                -- Recursively merge if both values are tables
                merge(target[k], v)
            else
                -- Override with source value
                target[k] = v
            end
        end
        return target
    end
    return merge(result, override_tbl or {})
end

function S.build_select(items, opts, callback)
    assert(type(items) == "table", "Items must be a table")
    assert(type(opts) == "table", "Options must be a table")
    assert(type(callback) == "function", "Callback must be a function")
    
    local Snacks = require("snacks")
    local Snacks_Select = Snacks.picker.select
    
    -- Default configurations
    local default_opts = { 
        prompt = "Techdeus IDE -> Choose a select prompt",
        with_cancel = true,  -- New option to control adding Cancel
        cancel_text = "Cancel" -- Customizable Cancel text
    }
    
    -- Merge options, with user options taking precedence
    local merged_opts = S.deep_merge(default_opts, opts)
    
    -- Process items
    local select_items = vim.deepcopy(items)
    
    -- Add Cancel option if needed
    if merged_opts.with_cancel then
        table.insert(select_items, merged_opts.cancel_text)
    end
    
    -- Remove our internal options before passing to Snacks
    local snacks_opts = vim.deepcopy(merged_opts)
    snacks_opts.with_cancel = nil
    snacks_opts.cancel_text = nil
    
    -- Debug.notify('Items: ' .. vim.inspect(select_items))
    
    Snacks_Select(select_items, snacks_opts, function(choice, idx)
        -- Handle nil values defensively
        local choice_str = "nil"
        local idx_str = "nil"
        
        if choice ~= nil then
            if type(choice) == "string" then
                choice_str = choice
            else
                choice_str = vim.inspect(choice)
            end
        end
        
        if idx ~= nil then
            idx_str = tostring(idx)
        end
        
        -- Debug.notify("Selected choice: " .. idx_str .. " - " .. choice_str)
        
        -- Validate the choice - handle both possible formats from Snacks
        if not choice then
            -- Debug.notify("Empty or nil selection")
            return { status = false, message = "invalid" }
        end
        
        -- Determine if this was the cancel option
        local is_cancel = false
        if type(choice) == "string" and choice == merged_opts.cancel_text then
            is_cancel = true
        elseif type(choice) == "table" and choice.text == merged_opts.cancel_text then
            is_cancel = true
        end
        
        if is_cancel then
            -- Debug.notify("Selection cancelled")
            return { status = true, message = "cancelled" }
        end
        
        -- Call the user-provided callback with the choice and index
        callback(choice, idx)
        return { status = true, message = "success" }
    end)
end




-- function S.build_select(items, opts, callback)
--     assert(type(items) == "table", "Items must be a table")
--     assert(type(opts) == "table", "Options must be a table")
--     assert(type(callback) == "function", "Callback must be a function")
    
--     local Snacks = require("snacks")
--     local Snacks_Select = Snacks.picker.select
--     local Select_items = vim.tbl_extend("force", items, { "Cancel" })

--      -- Default configurations
--      local default_opts = { 
--         prompt = "Techdeus IDE -> Choose a select prompt",
--         with_cancel = true,  -- New option to control adding Cancel
--         cancel_text = "Cancel" -- Customizable Cancel text
--     }
    
--     -- Merge options, with user options taking precedence
--     local merged_opts = S.deep_merge(default_opts, opts)

--      -- Process items
--      local select_items = vim.deepcopy(items)
    
--      -- Add Cancel option if needed
--      if merged_opts.with_cancel then
--          table.insert(select_items, merged_opts.cancel_text)
--      end
     
--      -- Remove our internal options before passing to Snacks
--      merged_opts.with_cancel = nil
--      merged_opts.cancel_text = nil
     
--      -- Debug.notify('Items: ' .. vim.inspect(select_items))

--      Snacks_Select(select_items, merged_opts, function(choice, idx)
--         -- Debug.notify("Selected choice: " .. idx .. vim.inspect(choice))
        
--         -- Validate the choice
--         if not choice or (idx == nil and choice == nil) then
--             -- Debug.notify("Invalid selection")
--             return { status = false, message = "invalid" }
--         end
        
--         -- Call the user-provided callback with the choice
--         callback(choice, idx)
--         return { status = true, message = "success" }
--     end)
-- end

return S

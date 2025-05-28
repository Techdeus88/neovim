local api = vim.api

local POPUP_WIDTH = 40
local BAR_MARGIN = 2

local PROGRESS_CHAR = "="
local REMAIN_CHAR = "="
local BAR_WIDTH_CHARS = POPUP_WIDTH - BAR_MARGIN

local colors = require("configs.colors").colors
api.nvim_set_hl(0, "MasonPopupBG", { bg = colors.bg_float })
api.nvim_set_hl(0, "MasonBarBG", { fg = colors.fg, bg = "NONE" })
api.nvim_set_hl(0, "MasonBarFG", { fg = colors.blue, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonTitle", { fg = colors.red, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonPkgName", { fg = colors.orange, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconProgress", { fg = colors.blue, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconOk", { fg = colors.green, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconError", { fg = colors.red, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonIconWarn", { fg = colors.orange, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonStatusOk", { fg = colors.green, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonStatusError", { fg = colors.red, bg = "NONE", bold = true })
api.nvim_set_hl(0, "MasonStatusWarn", { fg = colors.orange, bg = "NONE", bold = true })

local HL_BAR_BG = "MasonBarBG"
local HL_BAR_PROGRESS = "MasonBarFG"
local HL_TITLE = "MasonTitle"
local HL_POPUP_BG = "MasonPopupBG"
local HL_PKG_NAME = "MasonPkgName"
local HL_ICON_PROGRESS = "MasonIconProgress"
local HL_ICON_OK = "MasonIconOk"
local HL_ICON_ERROR = "MasonIconError"
local HL_ICON_WARN = "MasonIconWarn"

local SPINNER_FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local SPINNER_INTERVAL = 80

local ICON_OK = ""
local ICON_ERROR = ""
local ICON_WARN = ""

local STATUS = {
    PENDING = "pending",
    OK = "ok",
    FAIL = "fail",
    TIMEOUT = "timeout",
}

local STATUS_TEXT = {
    [STATUS.PENDING] = "Installing",
    [STATUS.OK] = "Installed",
    [STATUS.FAIL] = "Error",
    [STATUS.TIMEOUT] = "Timeout",
}

local refresh_timer = nil

local INSTALLATION_TIMEOUT = 120000

-- At the top of the file, add weak tables for better memory management
local state_cache = setmetatable({}, { __mode = "k" })
local tool_cache = setmetatable({}, { __mode = "k" })

-- Optimize the lsp_installer table
local lsp_installer = setmetatable({
    tools = {},
    win = nil,
    bufnr = nil,
    states = setmetatable({}, { __mode = "k" }), -- Make states table weak
    ns = api.nvim_create_namespace("custom_mason_progress"),
    callbacks = {},
    closed = false,
    start_time = nil,
}, { __mode = "k" })

local function make_bar(percent)
    local n_fill = math.floor(BAR_WIDTH_CHARS * percent / 100 + 0.5)
    local n_empty = BAR_WIDTH_CHARS - n_fill
    local bar = string.rep(PROGRESS_CHAR, n_fill) .. string.rep(REMAIN_CHAR, n_empty)
    return bar, n_fill, BAR_WIDTH_CHARS
end

local function center_text(text, width)
    local pad = math.max(0, math.floor((width - #text) / 2))
    return string.rep(" ", pad) .. text
end

local function get_status_info(state)
    local spinner_frame = (state.spinner_frame or 1) % #SPINNER_FRAMES
    local status_map = {
        [STATUS.PENDING] = {
            icon_str = SPINNER_FRAMES[spinner_frame + 1],
            text = state.message or STATUS_TEXT[STATUS.PENDING],
            hl = HL_ICON_PROGRESS
        },
        [STATUS.OK] = {
            icon_str = ICON_OK,
            text = STATUS_TEXT[STATUS.OK],
            hl = HL_ICON_OK
        },
        [STATUS.FAIL] = {
            icon_str = ICON_ERROR,
            text = STATUS_TEXT[STATUS.FAIL],
            hl = HL_ICON_ERROR
        },
        [STATUS.TIMEOUT] = {
            icon_str = ICON_WARN,
            text = STATUS_TEXT[STATUS.TIMEOUT],
            hl = HL_ICON_WARN
        },
    }
    return status_map[state.status] or { icon_str = "", text = "", hl = nil }
end

local function build_lines(tools, states)
    local lines = {}
    local line_meta = {}
    local bar_infos = {}

    -- Pre-allocate tables for better performance
    lines[1] = center_text("TECHDEUS INSTALLER", POPUP_WIDTH)
    line_meta[1] = {}

    -- Use ipairs for sequential access
    for i, tool in ipairs(tools) do
        local s = states[tool]
        if not s then goto continue end

        local base_idx = (i - 1) * 3 + 2
        lines[base_idx] = tool
        line_meta[base_idx] = { pkg_name = true }

        local bar, n_fill, n_total = make_bar(s.percent or 0)
        lines[base_idx + 1] = bar
        line_meta[base_idx + 1] = { bar = { n_fill = n_fill, n_total = n_total } }
        bar_infos[i] = { n_fill = n_fill, n_total = n_total }

        -- Optimize status text generation
        local status_info = get_status_info(s)
        lines[base_idx + 2] = status_info.icon_str .. " " .. status_info.text
        line_meta[base_idx + 2] = {
            icon_len = vim.str_utfindex(status_info.icon_str, "utf-8", #status_info.icon_str),
            icon_hl = status_info.hl,
        }

        ::continue::
    end
    return lines, bar_infos, line_meta
end

-- Add better error handling
local function safe_install_tool(tool, pkg)
    local handle = pkg:install()

    -- Add timeout handling
    local timeout_timer = vim.loop.new_timer()
    timeout_timer:start(INSTALLATION_TIMEOUT, 0, function()
        if lsp_installer.states[tool] and lsp_installer.states[tool].status == STATUS.PENDING then
            lsp_installer.states[tool].status = STATUS.TIMEOUT
            lsp_installer.states[tool].message = "Installation timed out"
            handle:close()
        end
    end)

    -- Add error recovery
    handle:on("error", function(err)
        if lsp_installer.states[tool] then
            lsp_installer.states[tool].status = STATUS.FAIL
            lsp_installer.states[tool].message = "Error: " .. tostring(err)
        end
        timeout_timer:stop()
        timeout_timer:close()
    end)

    return handle
end

-- Add proper cleanup function
local function cleanup_resources()
    if refresh_timer and not refresh_timer:is_closing() then
        refresh_timer:stop()
        refresh_timer:close()
        refresh_timer = nil
    end

    if update_debounce and not update_debounce:is_closing() then
        update_debounce:stop()
        update_debounce:close()
        update_debounce = nil
    end

    if lsp_installer.win and api.nvim_win_is_valid(lsp_installer.win) then
        api.nvim_win_close(lsp_installer.win, true)
    end

    -- Clear all caches
    for k in pairs(state_cache) do state_cache[k] = nil end
    for k in pairs(tool_cache) do tool_cache[k] = nil end

    -- Reset installer state
    lsp_installer.tools = {}
    lsp_installer.states = {}
    lsp_installer.callbacks = {}
    lsp_installer.closed = false
    lsp_installer.start_time = nil
end

local function update_popup()
    if lsp_installer.closed then
        return
    end

    if not lsp_installer.tools or #lsp_installer.tools == 0 then
        if lsp_installer.win and api.nvim_win_is_valid(lsp_installer.win) then
            api.nvim_win_close(lsp_installer.win, true)
        end
        lsp_installer.win = nil
        lsp_installer.bufnr = nil
        return
    end

    local tools = lsp_installer.tools
    local states = lsp_installer.states
    local height = #tools * 3 + 1
    local width = POPUP_WIDTH
    local col = vim.o.columns - width
    local row = 1
    local lines, bar_infos, line_meta = build_lines(tools, states)

    while #lines < height do
        table.insert(lines, "")
    end

    if lsp_installer.win and api.nvim_win_is_valid(lsp_installer.win) then
        pcall(api.nvim_win_set_config, lsp_installer.win, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
        })
        pcall(api.nvim_buf_set_lines, lsp_installer.bufnr, 0, -1, false, lines)
    else
        local bufnr = api.nvim_create_buf(false, true)
        vim.bo[bufnr].bufhidden = "wipe"
        api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        lsp_installer.win = api.nvim_open_win(bufnr, false, {
            style = "minimal",
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            border = "rounded",
            focusable = false,
            zindex = 250,
            noautocmd = true,
        })
        lsp_installer.bufnr = bufnr
        api.nvim_set_option_value(
            "winhighlight",
            "Normal:" .. HL_POPUP_BG .. ",NormalNC:" .. HL_POPUP_BG,
            { win = lsp_installer.win }
        )
    end
    if lsp_installer.bufnr then
        pcall(api.nvim_buf_clear_namespace, lsp_installer.bufnr, lsp_installer.ns, 0, -1)
        pcall(vim.highlight.range, lsp_installer.bufnr, lsp_installer.ns, HL_TITLE, { 0, 0 }, { 0, -1 })
        for i, _ in ipairs(tools) do
            local name_line = 1 + (i - 1) * 3
            local bar_line = name_line + 1
            local status_line = name_line + 2
            local barinfo = bar_infos[i]
            if not barinfo then
                goto continue
            end

            pcall(vim.highlight.range, lsp_installer.bufnr, lsp_installer.ns, HL_PKG_NAME, { name_line, 0 },
                { name_line, -1 })
            if barinfo.n_fill > 0 then
                pcall(
                    vim.highlight.range,
                    lsp_installer.bufnr,
                    lsp_installer.ns,
                    HL_BAR_PROGRESS,
                    { bar_line, 0 },
                    { bar_line, barinfo.n_fill }
                )
            end
            if barinfo.n_total > barinfo.n_fill then
                pcall(
                    vim.highlight.range,
                    lsp_installer.bufnr,
                    lsp_installer.ns,
                    HL_BAR_BG,
                    { bar_line, barinfo.n_fill },
                    { bar_line, barinfo.n_total }
                )
            end
            local meta = line_meta[status_line + 1]
            if meta and meta.icon_hl and meta.icon_len > 0 then
                pcall(
                    vim.highlight.range,
                    lsp_installer.bufnr,
                    lsp_installer.ns,
                    meta.icon_hl,
                    { status_line, 0 },
                    { status_line, meta.icon_len }
                )
            end

            ::continue::
        end
    end
end
-- Add debouncing for UI updates
local update_debounce = nil
local function debounced_update_popup()
    -- Only create a new timer if there isn't one already running
    if not update_debounce or update_debounce:is_closing() then
        update_debounce = vim.loop.new_timer()
    else
        -- If there's an existing timer, stop it but don't close it
        update_debounce:stop()
    end

    -- Start the timer with the new callback
    update_debounce:start(16, 0, vim.schedule_wrap(function()
        update_popup()
        -- Only close the timer after it's done
        if update_debounce and not update_debounce:is_closing() then
            update_debounce:stop()
            update_debounce:close()
            update_debounce = nil
        end
    end))
end

local function close_popup()
    if refresh_timer and not refresh_timer:is_closing() then
        refresh_timer:stop()
        refresh_timer:close()
        refresh_timer = nil
    end

    lsp_installer.closed = true

    if lsp_installer.win and api.nvim_win_is_valid(lsp_installer.win) then
        api.nvim_win_close(lsp_installer.win, true)
    end
    lsp_installer.win = nil
    lsp_installer.bufnr = nil

    cleanup_resources()

    vim.defer_fn(function()
        lsp_installer.tools = {}
        lsp_installer.states = {}
        lsp_installer.callbacks = {}
        lsp_installer.closed = false
    end, 200)
end

local function update_progress(tool, progress)
    if not lsp_installer.states[tool] then return end

    local state = lsp_installer.states[tool]
    state.has_real_progress = true

    if progress.message then
        state.message = progress.message
    end

    if progress.percent then
        -- Use exponential smoothing for progress updates
        local alpha = 0.3
        state.percent = math.min(95, math.floor(
            (1 - alpha) * (state.percent or 0) + alpha * progress.percent
        ))
    end
end

local function add_tools(new_tools)
    local added = false
    local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
    if not mason_registry_ok then
        vim.notify("Грешка при зареждане на mason-registry", vim.log.levels.ERROR)
        return false
    end

    for _, tool in ipairs(new_tools) do
        local name = tool
        local already = false
        for _, t in ipairs(lsp_installer.tools) do
            if t == name then
                already = true
                break
            end
        end
        if not already then
            local ok, pkg = pcall(mason_registry.get_package, name)
            if ok and pkg and not pkg:is_installed() then
                table.insert(lsp_installer.tools, name)
                lsp_installer.states[name] = {
                    status = STATUS.PENDING,
                    percent = 0,
                    spinner_frame = 0,
                    message = "Preparing...",
                    start_time = os.time(),
                }
                added = true
            end
        end
    end
    return added
end

local function are_tools_completed(tools)
    for _, tool in ipairs(tools) do
        if lsp_installer.states[tool] and lsp_installer.states[tool].status == STATUS.PENDING then
            return false
        end
    end
    return true
end

local function check_callbacks()
    local callbacks_to_remove = {}
    for i, callback_data in ipairs(lsp_installer.callbacks) do
        if are_tools_completed(callback_data.tools) then
            if callback_data.callback then
                callback_data.callback()
            end
            table.insert(callbacks_to_remove, i)
        end
    end
    for i = #callbacks_to_remove, 1, -1 do
        table.remove(lsp_installer.callbacks, callbacks_to_remove[i])
    end
    if #lsp_installer.callbacks == 0 then
        local all_done = true
        for _, s in pairs(lsp_installer.states) do
            if s.status == STATUS.PENDING then
                all_done = false
                break
            end
        end
        if all_done then
            local lsp_manager_ok, lsp_manager = pcall(require, "languages.lsp_manager")
            if lsp_manager_ok and lsp_manager then
                pcall(lsp_manager.set_installation_status, false)
            end
            vim.defer_fn(close_popup, 10000)
        end
    end
end

local function start_ui_refresh_timer()
    if refresh_timer and not refresh_timer:is_closing() then
        refresh_timer:stop()
        refresh_timer:close()
    end

    refresh_timer = vim.loop.new_timer()
    refresh_timer:start(
        0,
        50,
        vim.schedule_wrap(function()
            if lsp_installer.closed then
                if refresh_timer and not refresh_timer:is_closing() then
                    refresh_timer:stop()
                    refresh_timer:close()
                    refresh_timer = nil
                end
                return
            end

            local now = os.time()
            local elapsed_total = now - (lsp_installer.start_time or now)

            for _, tool in ipairs(lsp_installer.tools) do
                local state = lsp_installer.states[tool]
                if state and state.status == STATUS.PENDING then
                    state.spinner_frame = (state.spinner_frame or 0) + 1
                    local elapsed = now - (state.start_time or now)
                    local estimated_duration = 45
                    local auto_progress = math.min(95, (elapsed / estimated_duration) * 100)

                    if not state.has_real_progress and auto_progress > state.percent then
                        state.percent = auto_progress
                        if state.percent < 20 then
                            state.message = "Downloading..."
                        elseif state.percent < 50 then
                            state.message = "Extracting files..."
                        elseif state.percent < 80 then
                            state.message = "Installing components..."
                        else
                            state.message = "Finalizing..."
                        end
                    end
                end
            end

            -- Use debounced update instead of direct update
            debounced_update_popup()
        end)
    )
end

local M = {}

-- Add batch processing for installations
local function batch_install_tools(tools, batch_size)
    local batches = {}
    for i = 1, #tools, batch_size do
        table.insert(batches, { table.unpack(tools, i, math.min(i + batch_size - 1, #tools)) })
    end
    return batches
end

-- Optimize the ensure_mason_tools function
function M.ensure_mason_tools(tools, cb)
    if not tools or #tools == 0 then
        if cb then cb() end
        return
    end

    -- Validate dependencies first
    local deps = {
        mason_registry = pcall(require, "mason-registry"),
        lsp_manager = pcall(require, "languages.lsp_manager")
    }

    if not deps.mason_registry or not deps.lsp_manager then
        vim.notify("Required dependencies not available", vim.log.levels.ERROR)
        if cb then cb() end
        return
    end

    local mason_registry = require("mason-registry")
    local lsp_manager = require("languages.lsp_manager")

    -- Add tools first using add_tools
    if not add_tools(tools) then
        if cb then cb() end
        return
    end

    -- Process tools in batches
    local batches = batch_install_tools(tools, 3)
    local current_batch = 1

    local function process_next_batch()
        if current_batch > #batches then
            cleanup_resources()
            if cb then cb() end
            return
        end

        local batch_tools = batches[current_batch]

        -- Process current batch
        for _, tool in ipairs(batch_tools) do
            local pkg = mason_registry.get_package(tool)
            if pkg and not pkg:is_installed() then
                local handle = safe_install_tool(tool, pkg)

                handle:on(
                    "progress",
                    vim.schedule_wrap(function(progress)
                        update_progress(tool, progress)
                        debounced_update_popup()
                    end)
                )

                handle:once(
                    "closed",
                    vim.schedule_wrap(function()
                        vim.defer_fn(function()
                            if not lsp_installer or not lsp_installer.states or not lsp_installer.states[tool] then
                                return
                            end

                            local installed = false
                            pcall(function()
                                if pkg and pkg.is_installed then
                                    installed = pkg:is_installed()
                                end
                            end)

                            if lsp_installer.states and lsp_installer.states[tool] then
                                if installed then
                                    lsp_installer.states[tool].status = STATUS.OK
                                    lsp_installer.states[tool].percent = 100
                                    lsp_installer.states[tool].message = "Installation complete"
                                else
                                    lsp_installer.states[tool].status = STATUS.FAIL
                                    lsp_installer.states[tool].percent = 0
                                    lsp_installer.states[tool].message = "Installation failed"
                                end
                            end

                            pcall(check_callbacks)
                            debounced_update_popup()
                        end, 500)
                    end)
                )
            end
        end

        current_batch = current_batch + 1
        vim.defer_fn(process_next_batch, 1000)
    end

    -- Start the installation process
    lsp_manager.set_installation_status(true)
    lsp_installer.start_time = os.time()
    lsp_installer.closed = false

    -- Initialize UI
    start_ui_refresh_timer()
    update_popup()

    -- Start processing batches
    process_next_batch()

    -- Set timeout for the entire installation process
    vim.defer_fn(function()
        if lsp_installer.closed then
            return
        end
        for _, tool in ipairs(tools) do
            if lsp_installer.states[tool] and lsp_installer.states[tool].status == STATUS.PENDING then
                lsp_installer.states[tool].status = STATUS.TIMEOUT
                lsp_installer.states[tool].percent = 0
                lsp_installer.states[tool].message = "Installation timed out"
            end
        end

        if lsp_manager then
            lsp_manager.set_installation_status(false)
        end

        pcall(check_callbacks)
        cleanup_resources()
    end, INSTALLATION_TIMEOUT)
end

return M

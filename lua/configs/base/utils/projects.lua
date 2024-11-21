local P = {}

-- Configuration
P.config = {
    max_recent = 50,
    -- Default directories to scan
    base_dirs = {
        ["~/src"] = true,
        ["~/.config"] = true,
    },
    -- Project root patterns (from project.nvim)
    patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "pyproject.toml",
        "go.mod",
        "Cargo.toml",
        "composer.json",
        "pnpm-workspace.yaml",
        "nx.json",
        "rush.json",
        ".projectile",
        ".project",
    },
    -- Files to show in preview
    preview_files = {
        "README.md",
        "readme.md",
        "CONTRIBUTING.md",
        "package.json",
        "Cargo.toml",
        "pyproject.toml",
    },
    -- Ignore patterns
    ignore_patterns = {
        "node_modules",
        "target",
        "build",
        "dist",
    },
}

-- State
P.recent_projects = {}
P.project_cache = {}

function P.is_project_dir(dir)
    -- Check if directory contains any of our patterns
    for _, pattern in ipairs(P.config.patterns) do
        if vim.fn.glob(dir .. "/" .. pattern) ~= "" then return true end
    end
    return false
end

function P.get_all_projects()
    local projects = {}
    local seen = {}

    -- Add recent projects first
    for _, recent in ipairs(P.recent_projects) do
        if vim.fn.isdirectory(recent.dir) == 1 then
            table.insert(projects, recent)
            seen[recent.dir] = true
        end
    end

    -- Add projects from base directories
    for base_dir, enabled in pairs(P.config.base_dirs) do
        if enabled then
            local dir = vim.fn.expand(base_dir)
            if vim.fn.isdirectory(dir) == 1 then
                for name, type in vim.fs.dir(dir) do
                    if type == "directory" then
                        local full_path = dir .. "/" .. name
                        if not seen[full_path] then
                            -- Check if it's a project directory
                            if P.is_project_dir(full_path) then
                                table.insert(projects, { text = name, dir = full_path })
                                seen[full_path] = true
                            end
                        end
                    end
                end
            end
        end
    end

    -- Add LSP workspace folders if available
    for _, client in pairs(vim.lsp.get_active_clients()) do
        for _, workspace in pairs(client.config.workspace_folders or {}) do
            local path = vim.uri_to_fname(workspace.uri)
            if not seen[path] then
                local name = vim.fn.fnamemodify(path, ":t")
                table.insert(projects, { text = name, dir = path })
                seen[path] = true
            end
        end
    end

    return projects
end

function P.update_recent(project)
    -- Remove if already exists
    for i, recent in ipairs(P.recent_projects) do
        if recent.dir == project.dir then
            table.remove(P.recent_projects, i)
            break
        end
    end

    -- Add to front
    table.insert(P.recent_projects, 1, project)

    -- Trim if too long
    while #P.recent_projects > P.config.max_recent do
        table.remove(P.recent_projects)
    end
end

function P.create_picker()
    local projects = P.get_all_projects()

    -- Sort projects
    table.sort(projects, function(a, b)
        local a_word = string.lower(a.text)
        local b_word = string.lower(b.text)
        local first_a_char = string.sub(a_word, 1, 1)
        local first_b_char = string.sub(b_word, 1, 1)

        if first_a_char == "." then a_word = string.sub(a_word, 2) end
        if first_b_char == "." then b_word = string.sub(b_word, 2) end
        return a_word < b_word
    end)

    local initial_cwd = vim.fn.getcwd()

    local choose = function(item)
        if not item then
            vim.fn.chdir(initial_cwd)
            return
        end

        P.update_recent(item)
        vim.fn.chdir(item.dir)
        vim.schedule(function() require("mini.files").open(item.dir) end)
    end

    local preview = function(buf_id, item)
        if not item then return end

        local lines = {}
        -- First try to show important files
        local found_important = false
        for _, important_file in ipairs(P.config.preview_files) do
            local path = item.dir .. "/" .. important_file
            if vim.fn.filereadable(path) == 1 then
                found_important = true
                local content = vim.fn.readfile(path, "", 20) -- Read up to 20 lines
                vim.list_extend(lines, content)
                table.insert(lines, "")
            end
        end

        -- If no important files found, show directory listing
        if not found_important then
            for name, type in vim.fs.dir(item.dir) do
                local skip = false
                for _, pattern in ipairs(P.config.ignore_patterns) do
                    if name:match(pattern) then
                        skip = true
                        break
                    end
                end
                if not skip and not name:match("^%.") then
                    table.insert(lines, (type == "directory" and "📁 " or "📄 ") .. name)
                end
            end
        end

        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    end

    local mappings = {
        refresh = {
            char = "<C-r>",
            func = function()
                P.project_cache = {}
                local opts = P.create_picker()
                require("mini.pick").set_picker_items(opts.source.items)
            end,
        },
    }

    local source = {
        items = projects,
        name = "Projects",
        choose = choose,
        preview = preview,
        initial_cwd = initial_cwd,
    }

    return {
        source = source,
        mappings = mappings,
    }
end

function P.add_project_picker()
    local MiniPick = require("mini.pick")
    MiniPick.registry.projects = function()
        local opts = P.create_picker()
        local ProjectsPicker = MiniPick.start(opts)

        if ProjectsPicker == nil then
            vim.fn.chdir(opts.source.initial_cwd)
            return
        end
        return MiniPick.registry[ProjectsPicker]
    end
end

return P


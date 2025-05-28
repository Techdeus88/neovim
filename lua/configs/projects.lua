local P = {
  cache = {},
  config = {
    preview_files = { "README.md", ".git/config", "package.json" },
    ignore_patterns = { "node_modules", "%.git$", "%.cache$" },
    max_preview_lines = 20,
    max_recent = 10,
    -- Default directories to scan
    base_dirs = {
      ["~/src"] = true,
      ["~/.config"] = true,
      ["~/projects"] = true,
      ["~/work"] = true,
      ["~/dev"] = true,
      ["~/techdeus"] = true,
      ["~/workspace"] = true,
      ["~/techdeus/work"] = true,
      ["~/personal"] = true,
    },
    paths = {
      "~/src",
      "~/.config",
      "~/projects",
      "~/work",
      "~/dev",
      "~/techdeus",
      "~/workspace",
      "~/techdeus/work",
      "~/personal",
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
      "init.lua",
      "main.lua",
      "CMakeLists.txt",
      "build.gradle",
      "pom.xml",
      "mix.exs",
      "dune-project",
    },
    max_depth = 2,
    exclude_patterns = {
      "node_modules",
      ".git",
      "target"
    }
  }
}

---@param opts? {filter?: table<string, boolean>}
---@return fun():string?
function P.oldfiles(opts)
  opts = vim.tbl_deep_extend("force", {
    filter = {
      [vim.fn.stdpath("data")] = false,
      [vim.fn.stdpath("cache")] = false,
      [vim.fn.stdpath("state")] = false,
    },
  }, opts or {})
  ---@cast opts {filter:table<string, boolean>}

  local filter = {} ---@type {path:string, want:boolean}[]
  for path, want in pairs(opts.filter or {}) do
    table.insert(filter, { path = vim.fs.normalize(path), want = want })
  end
  local done = {} ---@type table<string, boolean>
  local i = 1
  local oldfiles = vim.v.oldfiles
  return function()
    while oldfiles[i] do
      local file = vim.fs.normalize(oldfiles[i], { _fast = true, expand_env = false })
      local want = not done[file]
      if want then
        done[file] = true
        for _, f in ipairs(filter) do
          if (file:sub(1, #f.path) == f.path) ~= f.want then
            want = false
            break
          end
        end
      end
      i = i + 1
      if want and vim.uv.fs_stat(file) then
        return file
      end
    end
  end
end

local function collect_projects()
  local projects = {}
  local seen = {}
  local dirs = {}

  -- Safe require for Snacks
  local s_ok, Snacks = pcall(require, "snacks")
  if not s_ok then
    vim.notify("Snacks not found, skipping recent projects", vim.log.levels.WARN)
    return projects
  end

  -- Collect recent projects
  for file in P.oldfiles() do
    local dir = vim.fs.dirname(vim.fs.find({ '.git', }, { path = file, upward = true })[1])
    if dir and not seen[dir] then
      seen[dir] = true
      table.insert(dirs, dir)
      if #dirs >= P.config.max_recent then
        break
      end
    end
  end

  -- Process recent directories
  for _, dir in ipairs(dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      table.insert(projects, {
        name = vim.fn.fnamemodify(dir, ":t"),
        path = dir,
        type = "recent"
      })
    end
  end

  -- Add projects from base directories
  for base_dir, enabled in pairs(P.config.base_dirs) do
    if enabled then
      local dir = vim.fn.expand(base_dir)
      if vim.fn.isdirectory(dir) == 1 then
        local ok, items = pcall(vim.fs.dir, dir)
        if ok then
          for name, type in items do
            -- Skip excluded patterns
            local skip = false
            for _, pattern in ipairs(P.config.exclude_patterns) do
              if name:match(pattern) then
                skip = true
                break
              end
            end

            if not skip and type == "directory" then
              local full_path = dir .. "/" .. name
              if not seen[full_path] then
                seen[full_path] = true
                table.insert(projects, {
                  name = name,
                  path = full_path,
                  type = P.is_git_repo(full_path) and "git" or "directory"
                })
              end
            end
          end
        end
      end
    end
  end

  return projects
end


-- Cache filesystem operations
local function cached_fs_dir(dir)
  if not P.cache[dir] then
    P.cache[dir] = {}
    for name, type in vim.fs.dir(dir) do
      P.cache[dir][name] = type
    end
  end
  return P.cache[dir]
end

-- Async file reading
local function read_file_async(path, callback)
  vim.schedule(function()
    local lines = vim.fn.readfile(path, "", P.config.max_preview_lines)
    callback(lines)
  end)
end

-- State
P.recent_projects = {}
P.project_cache = {}

function P.is_git_repo(path)
  local git_dir = path .. "/.git"
  return vim.fn.isdirectory(git_dir) == 1
end

function P.is_project_dir(dir)
  -- Check if directory contains any of our patterns
  for _, pattern in ipairs(P.config.patterns) do
    if vim.fn.glob(dir .. "/" .. pattern) ~= "" then return true end
  end
  return false
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

function P.create_project_picker()
  local projects = P.collect_projects()
  -- local project_nvim = require("project_nvim")
  -- local projects = project_nvim.get_recent_projects()
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
    local preview_done = false

    for _, important_file in ipairs(P.config.preview_files) do
      local path = item.dir .. "/" .. important_file
      if vim.fn.filereadable(path) == 1 then
        preview_done = true
        read_file_async(path, function(content)
          vim.list_extend(lines, content)
          vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
        end)
        break
      end
    end

    if not preview_done then
      local dir_contents = cached_fs_dir(item.dir)
      for name, type in pairs(dir_contents) do
        if not name:match("^%.") and not vim.tbl_contains(P.config.ignore_patterns, name) then
          table.insert(lines, (type == "directory" and "📁 " or "📄 ") .. name)
        end
      end
      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    end
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
    local opts = P.create_project_picker()
    local ProjectsPicker = MiniPick.start(opts)

    if ProjectsPicker == nil then
      vim.fn.chdir(opts.source.initial_cwd)
      return
    end
    return MiniPick.registry[ProjectsPicker]
  end
end

function P.get_projects()
  return collect_projects()
end

return P

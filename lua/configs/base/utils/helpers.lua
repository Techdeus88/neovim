local F = {}
local S = {}
local H = {}

-- Manage 'mini.test' screenshots ---------------------------------------------
function F.augroup(name, opts) return vim.api.nvim_create_augroup("techdeus_" .. name, opts or {}) end

local icons = require("configs.base.ui.icons")
local mini_files_group = F.augroup("Mini.Files", { clear = true })

function F.attach_file_browser(plugin_name, plugin_open)
  local previous_buffer_name
  vim.api.nvim_create_autocmd("BufEnter", {
    group = mini_files_group,
    desc = string.format("[%s] replacement  for Netrw", plugin_name),
    pattern = "*",
    callback = function()
      vim.schedule(function()
        local buffer_name = vim.api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(buffer_name) == 0 then
          _, previous_buffer_name = pcall(vim.fn.expand, "#:p:h")
          return
        end

        -- Avoid reopening when exiting without selecting a file
        if previous_buffer_name == buffer_name then
          previous_buffer_name = nil
          return
        else
          previous_buffer_name = buffer_name
        end

        -- Ensure no buffers remain with the directory name
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
        plugin_open(vim.fn.expand("%:p:h"))
      end)
    end,
  })
end

F.BufferTypeMap = {
  ["Mundo"] = { icon = "", text = "Mundo History" },
  ["MundoDiff"] = { icon = "", text = "Mundo Diff" },
  ["NvimTree"] = { icon = " ", text = "Tree" },
  ["fugitive"] = { icon = "", text = "Fugitive" },
  ["fugitiveblame"] = { icon = "", text = "Fugitive Blame" },
  ["help"] = { icon = "", text = "Help" },
  ["minimap"] = { icon = "", text = "Minimap" },
  ["oil"] = { icon = "", text = "Oil" },
  ["qf"] = { icon = "", text = "Quick Fix" },
  ["tabman"] = { icon = "", text = "Tab Manager" },
  ["tagbar"] = { icon = "", text = "Tagbar" },
  ["toggleterm"] = { icon = "", text = "Terminal" },
  ["FTerm"] = { icon = "", text = "Terminal" },
  ["NeogitStatus"] = { icon = "", text = "Neogit Status" },
  ["NeogitPopup"] = { icon = " ", text = "Neogit Popup" },
  ["NeogitCommitMessage"] = { icon = "", text = "Neogit Commit" },
  ["DiffviewFiles"] = { icon = "", text = "Diff View" },
  ["SidebarNvimOpen"] = { icon = "", text = "SideBar" },
  ["SidebarNvim"] = { icon = "", text = "SideBar" },
  ["incline"] = { icon = "", text = "Incline" },
  ["noice"] = { icon = "", text = "Noice" },
  ["alpha"] = { icon = "", text = "Alpha" },
  ["Alpha"] = { icon = "", text = "Alpha" },
  ["dashboard"] = { icon = "", text = "Dashboard" },
  ["Outline"] = { icon = "", text = "Outline" },
  ["Overseer"] = { icon = "", text = "Overseer" },
  ["undotree"] = { icon = "", text = "Undotree" },
  ["undotreeDiff"] = { icon = "", text = "Undotree Diff" },
  ["neotest-summary"] = { icon = "", text = "Neotest Summary" },
  ["neotest-output-panel"] = { icon = "", text = "Neotest Output Panel" },
  ["minifiles"] = { icon = "", text = "Mini Files" },
  ["markdown"] = { icon = "", text = "Markdown" },
  ["diff"] = { icon = "", text = "Diff Panel" },
  ["NoNeckPain"] = { icon = "", text = "No Neck Pain" },
  ["Scratch"] = { icon = "", text = "Scratch" },
  ["Trouble"] = { icon = "", text = "Trouble" },
  ["trouble"] = { icon = "", text = "Trouble" },
  [""] = { icon = icons.common.file, text = "[No FT]" },
}


function F.WindowViewFiletype(filetype, returntype)
  if returntype == nil then
    error("Return Type not passed in please fix")
    return
  end

  if filetype == nil then
    error("Filetype not passed in please fix")
    return
  end
  --[[
        * The method below describes the Filetype to Buffertype relationship.
        * This allows for the user to identify the type of window-buffer combination that stores & renders a particular file.
        * This is vital for the overall user experience. We use this to determine how to layout the application, placing the individual components, and other core behaviors such as autocommands, functions & language based specifics.
--]]

  local name = F.BufferTypeMap[filetype] and F.BufferTypeMap[filetype].text or "Editor"
  local icon = F.BufferTypeMap[filetype] and F.BufferTypeMap[filetype].icon or " "

  if returntype == "combo" then return icon .. " " .. name end

  if returntype == "separate" then return F.BufferTypeMap[filetype] or { icon = " ", text = "Editor" } end

  if returntype == "iO" then return icon end

  if returntype == "tO" then return name end

  return F.BufferTypeMap[filetype] or { icon = " ", text = "Editor" }
end

function F.PairsByKeys(t, f)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a, f)
  local i = 0 -- iterator variable
  local iter = function()
    -- iterator function
    i = i + 1
    if a[i] == nil then
      return nil
    else
      return a[i], t[a[i]]
    end
  end
  return iter
end

function F.GetModeNames()
  local mode_names = {
    n = "NORMAL",
    no = "NORMAL",
    nov = "NORMAL",
    noV = "NORMAL",
    ["no\22"] = "NORMAL",
    niI = "NORMAL",
    niR = "NORMAL",
    niV = "NORMAL",
    nt = "NORMAL",
    v = "VISUAL",
    vs = "VISUAL",
    V = "VISUAL",
    Vs = "VISUAL",
    ["\22"] = "VISUAL",
    ["\22s"] = "VISUAL",
    s = "SELECT",
    S = "SELECT",
    ["\19"] = "SELECT",
    i = "INSERT",
    ic = "INSERT",
    ix = "INSERT",
    R = "REPLACE",
    Rc = "REPLACE",
    Rx = "REPLACE",
    Rv = "REPLACE",
    Rvc = "REPLACE",
    Rvx = "REPLACE",
    c = "COMMAND",
    cv = "Ex",
    r = "...",
    rm = "M",
    ["r?"] = "?",
    ["!"] = "!",
    t = "TERM",
  }
  return mode_names
end

function F.ToggleTerm()
  local venv = vim.b["virtual_env"]
  local term = require("toggleterm.terminal").Terminal:new({
    env = venv and { VIRTUAL_ENV = venv } or nil,
    count = vim.v.count > 0 and vim.v.count or 1,
  })
  term:toggle()
end

function F.ToggleConcealLevel()
  if vim.o.conceallevel == 0 then
    vim.call("set", "conceallevel", 2)
  else
    vim.call("set", "conceallevel", 0)
  end
end

function F.IsTypeEditor(win_buf)
  local ft_type = vim.api.nvim_get_option_value("filetype", { buf = win_buf })
  local window_file_type = F.Window_viewfiletype(ft_type, "tO")
  return window_file_type == "Editor"
end

function F.MergeDefaultOpts(first, second)
  for k, v in pairs(second) do
    first[k] = v
  end
end

function F.Is_Current_Buffer_Map()
  local pres, Map = pcall(require, "mini.map")
  if not pres then return end
  return vim.api.nvim_get_current_buf() == Map.current.buf_data.source
end

function F.has_value(tab, val)
  for _, value in ipairs(tab) do
    if value == val then return true end
  end

  return false
end

function F.is_windows()
  local is_w = vim.fn.has("win32") == 1 -- true if on window
  return is_w
end

function F.is_android()
  local is_a = vim.fn.isdirectory("/data") == 1 -- true if on android
  return is_a
end

function F.remove_duplicate(tbl)
  local hash = {}
  local res = {}
  for _, v in ipairs(tbl) do
    if not hash[v] then
      res[#res + 1] = v
      hash[v] = true
    end
  end
  return res
end

-- Show Neoterm's active REPL, i.e. in which command will be executed when one
-- of `TREPLSend*` will be used
function _G.print_active_neoterm()
  local msg
  if vim.fn.exists("g:neoterm.repl") == 1 and vim.fn.exists("g:neoterm.repl.instance_id") == 1 then
    msg = "Active REPL neoterm id: " .. vim.g.neoterm.repl.instance_id
  elseif vim.g.neoterm.last_id ~= 0 then
    msg = "Active REPL neoterm id: " .. vim.g.neoterm.last_id
  else
    msg = "No active REPL"
  end

  print(msg)
end

-- Create scratch buffer and focus on it
function _G.new_scratch_buffer()
  local buf_id = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(0, buf_id)
  return buf_id
end

-- Make action for `<CR>` which respects completion and autopairs
--
-- Mapping should be done after everything else because `<CR>` can be
-- overridden by something else (notably 'mini-pairs.lua'). This should be an
-- expression mapping:
-- vim.api.nvim_set_keymap('i', '<CR>', 'v:lua._cr_action()', { expr = true })
--
-- Its current logic:
-- - If no popup menu is visible, use "no popup keys" getter. This is where
--   autopairs plugin should be used. Like with 'nvim-autopairs'
--   `get_nopopup_keys` is simply `npairs.autopairs_cr`.
-- - If popup menu is visible:
--     - If item is selected, execute "confirm popup" action and close
--       popup. This is where completion engine takes care of snippet expanding
--       and more.
--     - If item is not selected, close popup and execute '<CR>'. Reasoning
--       behind this is to explicitly select desired completion (currently this
--       is also done with one '<Tab>' keystroke).
function _G.cr_action()
  if vim.fn.pumvisible() ~= 0 then
    local item_selected = vim.fn.complete_info()["selected"] ~= -1
    return item_selected and H.keys["ctrl-y"] or H.keys["ctrl-y_cr"]
  else
    return require("mini.pairs").cr()
  end
end

-- Insert section
function _G.insert_section(symbol, total_width)
  symbol = symbol or "="
  total_width = total_width or 79

  -- Insert template: 'commentstring' but with '%s' replaced by section symbols
  local comment_string = vim.bo.commentstring
  local content = string.rep(symbol, total_width - (comment_string:len() - 2))
  local section_template = comment_string:format(content)
  vim.fn.append(vim.fn.line("."), section_template)

  -- Enable Replace mode in appropriate place
  local inner_start = comment_string:find("%%s")
  vim.fn.cursor(vim.fn.line(".") + 1, inner_start)
  vim.cmd([[startreplace]])
end

-- Execute current line with `lua`
-- Config.execute_lua_line = function()
--   local line = "lua " .. vim.api.nvim_get_current_line()
--   vim.api.nvim_command(line)
--   print(line)
--   vim.api.nvim_input("<Down>")
-- end

-- Tabpage with lazygit
function _G.open_lazygit()
  vim.cmd("tabedit")
  vim.cmd("setlocal nonumber signcolumn=no")

  -- Unset vim environment variables to be able to call `vim` without errors
  -- Use custom `--git-dir` and `--work-tree` to be able to open inside
  -- symlinked submodules
  vim.fn.termopen("VIMRUNTIME= VIM= lazygit --git-dir=$(git rev-parse --git-dir) --work-tree=$(realpath .)", {
    on_exit = function()
      vim.cmd("silent! :checktime")
      vim.cmd("silent! :bw")
    end,
  })
  vim.cmd("startinsert")
  vim.b.minipairs_disable = true
end

-- Toggle quickfix window
function _G.toggle_quickfix()
  local quickfix_wins = vim.tbl_filter(
    function(win_id) return vim.fn.getwininfo(win_id)[1].quickfix == 1 end,
    vim.api.nvim_tabpage_list_wins(0)
  )

  local command = #quickfix_wins == 0 and "copen" or "cclose"
  vim.cmd(command)
end

function _G.opts(desc) return { desc = desc } end

function _G.map(mode, keys, func, desc)
  mode = mode or "n"
  vim.keymap.set(mode, keys, func, _G.opts(desc))
end

-- Custom 'statuscolumn' for Neovim>=0.9
--
-- Revisit this with a better API.
--
-- Ideally, it should **efficiently** allow users to define each column for
-- a particular signs. Like:
-- - First column is for signs from 'gitsigns.nvim' and todo-comments.
-- - Second - diagnostic errors and warnings.
-- - Then line number.
-- - Then a column for everything else with highest priority.
--
-- Other notes:
-- - Make sure to allow fixed width for parts to exclude possibility of
--   horizontal shifts. Relevant, for example, for "absolute number" ->
--   "relative number" conversion.
-- - Set up `active()` and `inactive()` with change like in 'mini.statusline'.
-- - Should somehow not show any status column where it shouldn't be (like in
--   help files).
_G.statuscol_times = {}
function _G.statuscolumn()
  local start_time = vim.loop.hrtime()
  local lnum = vim.v.lnum
  -- Line part
  local line = H.get_line_statuscolumn_string(lnum, 3)
  -- Sign part
  local signs = H.get_sign_statuscolumn_string(lnum, 2)

  local res = string.format("%s%%=%s", signs, line)
  local end_time = vim.loop.hrtime()
  table.insert(_G.statuscol_times, 0.000001 * (end_time - start_time))
  return res
end

function F.get_line_statuscolumn_string(lnum, width)
  local number, relativenumber = vim.wo.number, vim.wo.relativenumber
  if not (number or relativenumber) then return "" end

  local is_current_line = lnum == vim.fn.line(".")

  -- Compute correct line number value
  local show_relnum = relativenumber and not (number and is_current_line)
  local text = vim.v.virtnum ~= 0 and "" or (show_relnum and vim.v.relnum or (number and lnum or ""))
  text = tostring(text):sub(1, width)

  -- Compute correct highlight group
  local hl = "LineNr"
  if is_current_line and vim.wo.cursorline then
    local cursorlineopt = vim.wo.cursorlineopt
    local cursorline_affects_number = cursorlineopt:find("number") ~= nil or cursorlineopt:find("both") ~= nil

    hl = cursorline_affects_number and "CursorLineNr" or "LineNr"
  elseif vim.wo.relativenumber then
    local relnum = vim.v.relnum
    hl = relnum < 0 and "LineNrAbove" or (relnum > 0 and "LineNrBelow" or "LineNr")
  end
  -- Combine result
  return string.format("%%#%s#%s ", hl, text)
end

function F.get_sign_statuscolumn_string(lnum, width)
  local signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), { group = "*", lnum = lnum })[1].signs
  if #signs == 0 then return string.rep(" ", width) end

  local parts, sign_definitions = {}, {}
  local cur_width = 0
  for i = #signs, 1, -1 do
    local name = signs[i].name

    local def = sign_definitions[name] or vim.fn.sign_getdefined(name)[1]
    sign_definitions[name] = def

    cur_width = cur_width + vim.fn.strdisplaywidth(def.text)
    local s = string.format("%%#%s#%s", def.texthl, vim.trim(def.text or ""))
    table.insert(parts, s)
  end
  local sign_string = table.concat(parts, "") .. string.rep(" ", width - cur_width)

  return sign_string
end

-- if vim.fn.exists('&statuscolumn') == 1 then
--   vim.o.signcolumn = 'no'
--   vim.o.statuscolumn = '%!v:lua.Config.statuscolumn()'
-- end

_G.minitest_screenshots = S
_G.helpers = F

function S.browse(dir_path)
  dir_path = dir_path or "tests/screenshots"
  S.files = vim.fn.readdir(dir_path)
  S.dir_path = dir_path
  local preview_item = function(x) return vim.fn.readfile(dir_path .. "/" .. x) end
  local ui_opts = { prompt = "Choose screenshot:", preview_item = preview_item }

  vim.ui.select(S.files, ui_opts, function(_, idx)
    if idx == nil then return end
    S.file_id = idx

    S.setup_windows()
    S.show()
  end)
end

function S.setup_windows()
  -- Set up tab page
  vim.cmd("tabnew")
  S.buf_id_text = vim.api.nvim_get_current_buf()
  S.win_id_text = vim.api.nvim_get_current_win()

  vim.cmd("setlocal bufhidden=wipe nobuflisted")
  vim.cmd("au CursorMoved <buffer> lua _G.minitest_screenshots.sync_cursor()")
  vim.cmd("belowright wincmd v | wincmd = | enew")
  S.buf_id_attr = vim.api.nvim_get_current_buf()
  S.win_id_attr = vim.api.nvim_get_current_win()
  vim.cmd("setlocal bufhidden=wipe nobuflisted")
  vim.cmd("au CursorMoved <buffer> lua _G.minitest_screenshots.sync_cursor()")

  vim.api.nvim_set_current_win(S.win_id_text)
  --stylua: ignore start
  local win_options = {
    colorcolumn = '',
    cursorline = true,
    cursorcolumn = true,
    fillchars = 'eob: ',
    foldcolumn = '0',
    foldlevel = 999,
    number = false,
    relativenumber = false,
    spell = false,
    signcolumn = 'no',
    wrap = false,
  }

  for name, value in pairs(win_options) do
    vim.api.nvim_win_set_option(S.win_id_text, name, value)
    vim.api.nvim_win_set_option(S.win_id_attr, name, value)
  end

  -- Set up behavior
  for _, buf_id in ipairs({ S.buf_id_text, S.buf_id_attr }) do
    vim.api.nvim_buf_set_keymap(buf_id, 'n', 'q', ':tabclose!<CR>', { noremap = true })
    vim.api.nvim_buf_set_keymap(buf_id, 'n', '<C-d>', '<Cmd>lua _G.minitest_screenshots.delete_current()<CR>',
      { noremap = true })
    vim.api.nvim_buf_set_keymap(buf_id, 'n', '<C-n>', '<Cmd>lua _G.minitest_screenshots.show_next()<CR>',
      { noremap = true })
    vim.api.nvim_buf_set_keymap(buf_id, 'n', '<C-p>', '<Cmd>lua _G.minitest_screenshots.show_prev()<CR>',
      { noremap = true })
  end
  --stylua: ignore end
end

function F.show(path)
  path = path or (S.dir_path .. "/" .. S.files[S.file_id])

  local lines = vim.fn.readfile(path)
  local n = 0.5 * (#lines - 3)

  local text_lines = { path, "Text" }
  vim.list_extend(text_lines, vim.list_slice(lines, 1, n + 1))
  vim.api.nvim_buf_set_lines(S.buf_id_text, 0, -1, true, text_lines)

  local attr_lines = { path, "Attr" }
  vim.list_extend(attr_lines, vim.list_slice(lines, n + 3, 2 * n + 3))
  vim.api.nvim_buf_set_lines(S.buf_id_attr, 0, -1, true, attr_lines)

  pcall(function() require("mini.trailspace").unhighlight() end)
  require("mini.trailspace").unhighlight()
end

function F.sync_cursor()
  -- Don't use `vim.api.nvim_win_get_cursor()` because of multibyte characters
  local line, col = vim.fn.winline(), vim.fn.wincol()
  local cur_win_id = vim.api.nvim_get_current_win()
  -- Don't use `vim.api.nvim_win_set_cursor()`: it doesn't redraw cursorcolumn
  local command = string.format("windo call setcursorcharpos(%d, %d)", line, col)
  vim.cmd(command)
  vim.api.nvim_set_current_win(cur_win_id)
end

function F.show_next()
  S.file_id = math.fmod(S.file_id, #S.files) + 1
  S.show()
end

function F.show_prev()
  S.file_id = math.fmod(S.file_id + #S.files - 2, #S.files) + 1
  S.show()
end

F.delete_current = function()
  local path = S.dir_path .. "/" .. S.files[S.file_id]
  vim.fn.delete(path)
  print("Deleted file " .. vim.inspect(path))
end

function F.get_name_from_path(path)
  -- "/Users/AgentSullivan/.config"
  local length = #path
  local index
  for i = 1, length do
    local char = string.sub(path, i, i)
    if char == "/" then index = i end
  end
  local name = string.sub(path, index + 1)
  return name
end

function F.GitPushPull(action, tense)
  local Job = require("plenary.job")
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]

  vim.ui.select({ "Yes", "No" }, {
    prompt = action:gsub("^%l", string.upper) .. " commits to/from " .. "'origin/" .. branch .. "'?",
  }, function(choice)
    if choice == "Yes" then
      Job:new({
        command = "git",
        args = { action },
        on_exit = function() F.GitRemoteSync() end,
      }):start()
    end
  end)
end

function F.GitPull() F.GitPushPull("pull", "from") end

function F.GitPush() F.GitPushPull("push", "to") end

function F.ChangeFiletype()
  vim.ui.input({ prompt = "Change filetype to: " }, function(new_ft)
    if new_ft ~= nil then vim.bo.filetype = new_ft end
  end)
end

function F.ListBranches()
  local branches = vim.fn.systemlist([[git branch 2>/dev/null]])
  local new_branch_prompt = "Create new branch"
  table.insert(branches, 1, new_branch_prompt)

  vim.ui.select(branches, {
    prompt = "Git branches",
  }, function(choice)
    if choice == nil then return end

    if choice == new_branch_prompt then
      local new_branch = ""
      vim.ui.input({ prompt = "New branch name:" }, function(branch)
        if branch ~= nil then vim.fn.systemlist("git checkout -b " .. branch) end
      end)
    else
      vim.fn.systemlist("git checkout " .. choice)
    end
  end)
end

-- Helper data ================================================================
-- Commonly used keys
F.keys = {
  ["cr"] = vim.api.nvim_replace_termcodes("<CR>", true, true, true),
  ["ctrl-y"] = vim.api.nvim_replace_termcodes("<C-y>", true, true, true),
  ["ctrl-y_cr"] = vim.api.nvim_replace_termcodes("<C-y><CR>", true, true, true),
}

return F

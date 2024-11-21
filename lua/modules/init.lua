local configs = {}

configs["1_modules_start_me"] = function()
--17 Modules--
  local modules_start_me = require("modules.start_me")
  modules_start_me.load()
end

configs["2_modules_mini_me"] = function()
  local modules_mini_me = require("modules.mini_me")
  modules_mini_me.load()
  --24 mini-modules **Loads with mini.nvim in 21ms**
end

configs["3_modules_edit_me"] = function()
  local modules_edit_me = require("modules.edit_me")
  modules_edit_me.load()
  --43 Modules--
end

configs["4_modules_build_me"] = function()
local modules_build_me = require("modules.build_me")
modules_build_me.load()
--14 Modules--
end

configs["5_modules_serve_me"] = function()
  local modules_serve_me = require("modules.serve_me")
modules_serve_me.load()
--28 Modules--
end

configs["6_modules_test_me"] = function()
local modules_test_me = require("modules.test_me")
modules_test_me.load()
-- 18 MODULES--
end

-- Total Configs
-- 120 MODULES--
-- 144 w/ Mini-packages
return configs

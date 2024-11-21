--[[
--                                     ░░
--  ███████   █████   ██████  ██    ██ ██ ██████████
-- ░░██░░░██ ██░░░██ ██░░░░██░██   ░██░██░░██░░██░░██
--  ░██  ░██░███████░██   ░██░░██ ░██ ░██ ░██ ░██ ░██
--  ░██  ░██░██░░░░ ░██   ░██ ░░████  ░██ ░██ ░██ ░██
--  ███  ░██░░██████░░██████   ░░██   ░██ ███ ░██ ░██
-- ░░░   ░░  ░░░░░░  ░░░░░░     ░░    ░░ ░░░  ░░  ░░
--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ techdeus <techdeusms@gmail.com>
-- ░▓ code   ▓ https://github.com/Techdeus88/dot-files
-- ░▓ mirror ▓ https://github.com/Techdeus88/dot-files
-- ░▓▓▓▓▓▓▓▓▓▓
-- ░░░░░░░░░░
--
-- --
-- HELLO, welcome to the Techdeus SHOW!
-- --
-- ---------------------------------------
-- Entry point of the deus custom neovim configs.
-- ---------------------------------------
-- --
--]]
--=========================== Initialization ========================--
_G.start_time = vim.loop.hrtime()
require("core")
_G.end_time = vim.loop.hrtime()

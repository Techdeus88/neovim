
local test_table = {
    a = 1,
    b = "hello",
    c = {
        d = true,
        e = {
            f = "nested"
        }
    }
}
local M = require("base.metrics")
-- Test with a circular reference
local circular = {}
circular.self = circular

-- Test with deep nesting
local deep = {}
local current = deep
for i = 1, 200 do
    current[i] = {}
    current = current[i]
end

-- Test all formats
print("Testing indent format:")
print(table.concat(M.handle_tbl_values(test_table, "indent"), "\n"))

print("\nTesting json format:")
print(table.concat(M.handle_tbl_values(test_table, "json"), "\n"))

print("\nTesting tab format:")
print(table.concat(M.handle_tbl_values(test_table, "tab"), "\n"))

print("\nTesting circular reference:")
print(table.concat(M.handle_tbl_values(circular, "indent"), "\n"))

print("\nTesting deep nesting:")
print(table.concat(M.handle_tbl_values(deep, "indent"), "\n"))

local color_utils = {}

-- Color format detection
local function detect_color_format(color)
    if type(color) == "string" then
        if color:match("^#") then
            return "hex"
        elseif color:match("^hsl") then
            return "hsl"
        end
    elseif type(color) == "table" and #color == 3 then
        return "rgb"
    end
    return nil
end

-- Conversion utilities
local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    return {
        tonumber(hex:sub(1,2), 16),
        tonumber(hex:sub(3,4), 16),
        tonumber(hex:sub(5,6), 16)
    }
end

local function rgb_to_hex(r, g, b)
    return string.format("#%02x%02x%02x", r, g, b)
end

local function rgb_to_hsl(r, g, b)
    r, g, b = r/255, g/255, b/255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, l
    l = (max + min) / 2

    if max == min then
        h, s = 0, 0
    else
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return {h * 360, s * 100, l * 100}
end

local function hsl_to_rgb(h, s, l)
    h, s, l = h/360, s/100, l/100
    local function hue_to_rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end

    local r, g, b
    if s == 0 then
        r, g, b = l, l, l
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue_to_rgb(p, q, h + 1/3)
        g = hue_to_rgb(p, q, h)
        b = hue_to_rgb(p, q, h - 1/3)
    end

    return {
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5)
    }
end

-- Main inversion function
function color_utils.invert_color(color)
    if not color then return end
    local format = detect_color_format(color)
    if not format then
        error("Invalid color format")
    end

    if format == "hex" then
        local rgb = hex_to_rgb(color)
        local hsl = rgb_to_hsl(rgb[1], rgb[2], rgb[3])
        hsl[1] = (hsl[1] + 180) % 360
        local rgb_inverted = hsl_to_rgb(hsl[1], hsl[2], hsl[3])
        return rgb_to_hex(rgb_inverted[1], rgb_inverted[2], rgb_inverted[3])
    
    elseif format == "rgb" then
        local hsl = rgb_to_hsl(color[1], color[2], color[3])
        hsl[1] = (hsl[1] + 180) % 360
        return hsl_to_rgb(hsl[1], hsl[2], hsl[3])
    
    elseif format == "hsl" then
        local h, s, l = color:match("hsl%((%d+),(%d+)%%,(%d+)%%%)") 
        h = (tonumber(h) + 180) % 360
        return string.format("hsl(%d,%s%%,%s%%)", h, s, l)
    end
end

return color_utils
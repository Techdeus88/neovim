local config = {}

config.enmet = function()
   
    return {
        settings = {
            filetypes = {
                "html",
                "css",
                "sass",
                "scss",
                "less",
                "svelte",
            },
        },
        setup = function() end,
    } 
end

return config
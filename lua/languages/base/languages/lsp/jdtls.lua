local config = {}

config.jdtls = function()
    return {
        settings = {},
        setup = function() 
            return {
            notifications = {
                dap = false,
            },
            root_markers = {
                "settings.gradle",
                "settings.gradle.kts",
                "pom.xml",
                "build.gradle",
                "mvnw",
                "gradlew",
                "build.gradle",
                "build.gradle.kts",
                ".git",
            },
        }
    end,
}
end

return config
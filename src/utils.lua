local utils_module = {}
local config = require "src/config"

function utils_module.check_for_bump(name)
    if not name then
        return nil
    end

    local meta_data = io.open(config.BUMPS .. "/" .. name .. "/" .. config.MD_NAME)
    return meta_data
end

function utils_module.get_file_name_from_path(path)
    return path:match("([a-zA-Z-]*.[a-zA-Z]*)$")
end

function utils_module.error404()
    return "<h1>\"Welcome to die|</h1>\n<!-- Jesus this layout -->"
end

return utils_module

local config = require "src/config"
local utils = require "src/utils"
local fuck_json = require "src/JSON"

function static(uri)
    local filename = utils.get_file_name_from_path(uri)
    local subdomain_arg = string.match(arg[2], utils.subdomain_match)
    local meta_data = utils.check_for_bump(subdomain_arg)

    if filename == "pickles.png" then
        local f = assert(io.open("./pickles.png"))
        print(f:read("*all"))
        f:close()
        return
    end

    if not meta_data then
        return utils.error404()
    end

    -- TODO: Search through metadata for assoc. files and return the one
    -- requested, otherwise 404.
    local decoded = fuck_json:decode(meta_data:read("*all"))
    meta_data:close()
    if filename == decoded["image"] or filename == decoded["webm"] or filename == decoded["imageRepeat"] then
        local path = utils.build_bump_path(subdomain_arg)
        local f = assert(io.open(path .. "/" .. filename))
        print(f:read("*all"))
        f:close()
        return
    end
    return utils.error404()
end

print(static(arg[3]))

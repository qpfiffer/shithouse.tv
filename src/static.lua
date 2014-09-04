local config = require "src/config"
local utils = require "src/utils"

function static(uri)
    local subdomain_arg = string.match(arg[2], "[a-zA-Z]*")
    local meta_data = utils.check_for_bump(subdomain_arg)

    if not meta_data then
        return utils.error404()
    end

    -- TODO: Search through metadata for assoc. files and return the one
    -- requested, otherwise 404.
    io.close(meta_data)
    return utils.error404()
end

print(static(arg[3]))

local config = require "src/config"
local utils = require "src/utils"

function static(uri)
    local subdomain_arg = string.match(arg[2], "[a-zA-Z]*")
    local meta_data = check_for_bump(subdomain_arg)

    if not meta_data then
        return utils.error404()
    end

    return ""
end

print(static(uri))

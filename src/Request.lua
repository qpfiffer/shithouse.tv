local Utils = require("src/Utils")
local Request = {}
Request.__index = Request

function Request:init(host, verb, path, post_data_json)
    init = {
        host = host,
        verb = verb,
        path = path,
        post_data_json = post_data_json,
    }

    setmetatable(init, self)
    return init
end

function Request:get_subdomain()
    return string.match(self.host, Utils.subdomain_match)
end

return Request

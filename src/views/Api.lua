local Api = {}
Api.__index = Api

local Template = require("src/Template")
local Response = require("src/Response")

function Api:init(host, path)
    init = {
        host = host,
        path = path,
    }

    setmetatable(init, self)
    self.__index = self
    return init
end

function Api:get()
    local f = assert(io.open("templates/api.html", "r"))
    local rendered = Template.render(f, {})
    f:close()

    return Response:init(rendered, 200, "application/json")
end

return Api

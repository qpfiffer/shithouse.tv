local Bump = {}
Bump.__index = Bump

local fuck_json = require("src/JSON")
local Utils = require("src/Utils")
local Template = require("src/Template")

local Root = require("src/views/Root")
local Response = require("src/Response")

function Bump:init(host, path)
    init = {
        host = host,
        path = path,
    }

    setmetatable(init, self)
    self.__index = self
    return init
end

function Bump:get(request)
    local f = assert(io.open("templates/bump.html", "r"))

    local subdomain = request:get_subdomain()
    local meta_data = Utils.check_for_bump(subdomain)

    if not meta_data then
        return Root:init():get(request, "NO SUCH BUMP PLS MAKE")
    end

    local ctext = fuck_json.decode(meta_data:read("*all"))
    local rendered = Template.render(f, ctext)
    meta_data:close()
    f:close()

    return Response:init(rendered, 200)
end

return Bump

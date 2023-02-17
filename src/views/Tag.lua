local Tag = {}
Tag.__index = Tag

local config = require("src/config")
local fuck_json = require("src/JSON")
local Utils = require("src/Utils")
local Template = require("src/Template")

local Root = require("src/views/Root")

local Response = require("src/Response")

function Tag:init(host, path)
    init = {
        host = host,
        path = path,
    }

    setmetatable(init, self)
    self.__index = self
    return init
end

function Tag:_fuck_you(request, error_msg)
    return Root:init():get(request, error_msg)
end

function Tag:get(request, errmsg)
    local tag = request.path:match(Utils.subdomain_match .. "$")
    if not tag or tag == "" then
        return self:_fuck_you(request, "no")
    end

    local f = assert(io.open("templates/tag.html", "r"))
    local rendered = Template.render(f, { ["msg"] = "All bumps for tag ",
                                          ["filter"] = "yYy all_bumps_for_tag ",
                                          ["tag"] = tag })
    f:close()

    return Response:init(rendered, 200)
end

return Tag

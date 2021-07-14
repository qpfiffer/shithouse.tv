local App = {}
App.__index = App

local Request = require("src/Request")
local Response = require("src/Response")
local Router = require("src/Router")

function App:init(conf)
    init = {
        router = Router:init()
    }

    setmetatable(init, self)
    return init
end

function App:handle_request(host, path, verb, post_data_json)
    local _verb = string.lower(verb)
    local cls = self.router:get_route(host, path)
    if not cls then
        return Response:init("Welcome to Die", 404)
    end

    if not cls[_verb] then
        local dbg = require("debugger")
        dbg()
        return Response:init("Welcome to Die (No method matching " .. _verb .. " found.)", 404)
    end

    local request = Request:init(host, verb, path, post_data_json)
    local resp = cls[_verb](cls, request)
    return resp
end

return App

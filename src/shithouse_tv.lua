local config = require("src/config")

-- Big Kahuna
local App = require("src/App")
local Utils = require("src/Utils")

-- Views
local Api = require("src/views/Api")
local Bump = require("src/views/Bump")
local BumpTag = require("src/views/BumpTag")
local Root = require("src/views/Root")
local Static = require("src/views/Static")
local Tag = require("src/views/Tag")

function main()
    local app = App:init()

    app.router:add_route(Static:init("*", "^/([a-zA-Z0-9_-]+%.[a-zA-Z]+)$"))
    app.router:add_route(Bump:init("*", "/"))

    app.router:add_route(BumpTag:init(config.HOST, "^/tag/" .. Utils.subdomain_match .."$"))
    app.router:add_route(Tag:init(config.HOST, "^/bumps_with_tag/" .. Utils.subdomain_match .."$"))

    app.router:add_route(Root:init(config.HOST, "/"))
    app.router:add_route(Api:init(config.API_URL, "/"))

    return app
end

return main()

local App = require("src/App")
local Api = require("src/views/Api")

function test_it_works()
    local app = App:init()
    app.router:add_route(Api:init("api.shithouse.tv", "/"))
    local r = app:handle_request("api.shithouse.tv", "/", "GET")
    assert(r.status_code == 200, "Wrong status code")
end

function test()
    test_it_works()
end

test()

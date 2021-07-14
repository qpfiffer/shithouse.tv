local Router = require("src/Router")

local function _testable_rt(host, path)
    return {
        host = host,
        path = path,
        itsme = true
    }
end

local function _is_rt(match)
    return match and match["itsme"]
end

function test_can_match_wildcards()
    local router = Router:init()
    router:add_route(_testable_rt("*", "/"))
    local c = router:get_route("api.shithouse.tv", "/")
    local d = router:get_route("housecat.shithouse.tv", "/")
    if not _is_rt(c) or not _is_rt(d) then error("Could not get route") end
end

function test_it_works()
    local router = Router:init()
    router:add_route(_testable_rt("api.shithouse.tv", "/"))
    local c = router:get_route("api.shithouse.tv", "/")
    if not _is_rt(c) then error("Could not get route") end
end

function test_can_match_regex_static_url()
    local router = Router:init()
    router:add_route(_testable_rt("*", "^/([a-zA-Z0-9_-]+%.[a-zA-Z]+)$"))
    local c = router:get_route("api.shithouse.tv", "/asdf.gif")
    local d = router:get_route("api.shithouse.tv", "/asdf2.gif")
    local e = router:get_route("api.shithouse.tv", "/1-a-_asdf2.jpeg")
    local should_not_match = router:get_route("api.shithouse.tv", "/does/not/match.gif")
    if not _is_rt(c) or not _is_rt(d) or not _is_rt(e) then error("Could not get route") end
    if _is_rt(should_not_match)  then error("Matched too much on static.") end
end

function test()
    test_can_match_wildcards()
    test_can_match_regex_static_url()
    test_it_works()
end

test()

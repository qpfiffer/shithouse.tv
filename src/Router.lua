local Router = {}
Router.__index = Router

function Router:init(conf)
    local this = {
        routes = {}
    }
    setmetatable(this, self)
    return this
end

function Router:add_route(route)
    if not self.routes[route.host] then
        self.routes[route.host] = {}
    end

    if not self.routes[route.host][route.path] then
        self.routes[route.host][route.path] = {}
    end

    table.insert(self.routes[route.host][route.path], route)
end

function Router:_get_path(path, paths)
    for possible_path, matched_routes in pairs(paths) do
        -- Shitty way to detect regex
        local is_regex = possible_path:match(".*[.*].*") or nil
        if path == possible_path and not is_regex then
            -- XXX: Loop through each of these.
            return matched_routes[1]
        elseif is_regex and path:match(possible_path) ~= nil then
            -- XXX: Loop through each of these.
            return matched_routes[1]
        end
    end
end

function Router:get_route(host, path)
    -- Match specific hosts first
    for possible_host, paths in pairs(self.routes) do
        if host == possible_host then
            local possible_path = self:_get_path(path, paths)
            if possible_path then
                return possible_path
            end
        end
    end

    for possible_host, paths in pairs(self.routes) do
        if possible_host == "*" then
            local possible_path = self:_get_path(path, paths)
            if possible_path then
                return possible_path
            end
        end
    end
end

return Router

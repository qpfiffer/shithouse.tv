local template = require "src/template"
local fuck_json = require "src/JSON"

local HOST = "shitless.com"
local BUMPS = "./tv"
local MD_NAME = "meta.json"

function check_for_bump(name)
    if not name then
        return nil
    end

    local meta_data = io.open(BUMPS .. "/" .. name .. "/" .. MD_NAME)
    return meta_data
end

function bump(hostname)
    local f = io.open("templates/bump.html", "r")
    local ctext = {}

    local meta_data = check_for_bump(name)

    if meta_data == nil then
        return root("NO SUCH BUMP PLS MAKE")
    end

    local rendered = template.render(f, ctext)
    f:close()
    return rendered
end

function root(errmsg)
    local f = io.open("templates/index.html", "r")
    local rendered = template.render(f, { ["error_msg"] = errmsg })
    f:close()

    return rendered
end

function main()
    if arg[3] ~= nil then
        local decoded = fuck_json:decode(arg[3])
        local subdomain = decoded["subdomain"]:match("[a-zA-Z-]*")
        --for key, value in pairs(decoded) do print(key .. ", " .. value .. "\n") end

        -- 0. Verify Data
        if subdomain == nil or subdomain == "" then
            return root("You need subdomain")
        end

        local meta_data = check_for_bump(subdomain)
        if meta_data ~= nil then
            meta_data:close()
            return root("Bump already exists")
        end

        -- 1. Write metadata to metadata file
        -- 2. Truncate music
        -- 3. Render template with context of decoded
        return bump(subdomain)
    end

    local subdomain_arg = string.match(arg[2], "[a-zA-Z]*")

    if subdomain_arg == string.match(HOST, "[a-zA-Z]*") then
        return root()
    else
        return bump(subdomain_arg)
    end
end

print(main())

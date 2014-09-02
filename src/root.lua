local template = require "src/template"
local fuck_json = require "src/JSON"

local HOST = "shitless.com"
local BUMPS = "./tv"
local MD_NAME = "meta.json"

function bump(hostname)
    local f = io.open("templates/bump.html", "r")
    local ctext = {}

    local meta_data = io.open(BUMPS .. "/" .. hostname .. "/" .. MD_NAME)

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
    local subdomain = string.match(arg[2], "[a-zA-Z]*")

    if arg[3] ~= nil then
        local decoded = fuck_json:decode(arg[3])
        -- for key,value in pairs(decoded) do print(key .. ", " .. value .. "\n") end
        -- 1. Write metadata to metadata file
        -- 2. Truncate music
        -- 3. Render template with context of decoded
    end

    if subdomain == string.match(HOST, "[a-zA-Z]*") then
        return root()
    else
        return bump(subdomain)
    end
end

print(main())

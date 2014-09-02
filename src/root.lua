local template = require "src/template"
local HOST = "shitless.com"
local BUMPS = "./tv"
local MD_NAME = "meta.DAT"

function bump(hostname)
    local f = io.open("templates/bump.html", "r")
    local ctext = {}

    local meta_data = io.open(BUMPS .. "/" .. hostname .. "/" .. MD_NAME)

    if meta_data == nil then
        return root("No such bump. Make it?")
    end

    local rendered = template.render(f, ctext)
    f:close()
    return rendered
end

function root(errmsg)
    local f = io.open("templates/index.html", "r")
    local rendered = template.render(f, { ["error"] = errmsg })
    f:close()

    return rendered
end

function main()
    local subdomain = string.match(arg[2], "[a-zA-Z]*")

    if subdomain == string.match(HOST, "[a-zA-Z]*") then
        return root()
    else
        return bump(subdomain)
    end
end

print(main())

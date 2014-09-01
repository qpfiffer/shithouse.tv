local template = require "src/template"
local HOST = "shitless.com"

function bump(hostname)
    local subdomain = string.match(hostname, "[a-zA-Z]*")

    if subdomain == string.match(HOST, "[a-zA-Z]*") then
        local f = io.open("templates/index.html", "r")
        print(template.render(f))
        f:close()
        return
    end

    -- Render the bump instead
    local f = io.open("templates/bump.html", "r")
    print(template.render(f))
    f:close()

end

function root()
    bump(arg[2])
end

root()

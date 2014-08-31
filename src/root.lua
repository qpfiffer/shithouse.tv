-- Well, this is pretty neat.
local HOST = "shitless.com"
function bump(hostname)
    local subdomain = string.match(hostname, "[a-zA-Z]*")

    if subdomain == string.match(HOST, "[a-zA-Z]*") then
        local f = io.open("templates/index.html", "r")
        print(f:read("*all"))
        f:close()
        return
    end

    local f = io.open("templates/bump.html", "r")
    print(f:read("*all"))
    f:close()

end

function root()
    if arg[2] ~= HOST then
        bump(arg[2])
    else
        local f = io.open("templates/index.html", "r")
        print(f:read("*all"))
        f:close()
    end
end

root()

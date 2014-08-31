-- Well, this is pretty neat.
function root()
    if arg[2] ~= "shithouse.tv" then
        local f = io.open("templates/index.html", "r")
        print(f:read("*all"))
        f:close()
    end
end

root()

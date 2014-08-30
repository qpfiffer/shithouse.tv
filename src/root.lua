-- Well, this is pretty neat.
function main_page(func)
    print([[
<!DOCTYPE html>
<html>
    <body>]])
    func()
    print([[
    </body>
</html>]])
end

function root()
    if arg[2] ~= "shithouse.tv" then
        print([[
        <form method="POST">
            <label for="subdomain">Subdomain:</label>
            <input id="subdomain" />
            <input type="submit" />
        </form>
]])
    end
end

main_page(root)

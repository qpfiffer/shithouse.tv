local template = require "src/template"
local fuck_json = require "src/JSON"
local config = require "src/config"
local utils = require "src/utils"

function bump(hostname)
    local f = io.open("templates/bump.html", "r")
    local ctext = {}

    local meta_data = utils.check_for_bump(name)

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

function verify(bump_data)
    local decoded = fuck_json:decode(bump_data)
    local v_subdomain = decoded["subdomain"]:match("[a-zA-Z-]*")
    local verified = {}
    --for key, value in pairs(decoded) do print(key .. ", " .. value .. "\n") end

    -- 0. Verify Data
    -- Check for an okay name
    if not v_subdomain or v_subdomain == "" then
        return root("You need subdomain")
    end

    -- Check to see if it already exists
    local meta_data = utils.check_for_bump(v_subdomain)
    if meta_data then
        meta_data:close()
        return root("Bump already exists")
    end
    verified["subdomain"] = v_subdomain

    -- Make sure that the bg-color is okay
    local v_bgcolor = decoded["bg-color"]:match("(%d%d%d%d%d%d)")
    if not v_bgcolor then
        return root("Pick better background color pls")
    end
    verified["bg-color"] = v_bgcolor

    -- Make sure there is at least an image
    local v_image = decoded["image"]
    if not v_image then
        return root("You need image")
    end
    verified["image"] = v_image
    --print("IMAGE IS " .. v_image)

    -- 1. Write metadata to metadata file
    -- 2. Truncate music
    -- 3. Render template with context of decoded
    return v_subdomain
end

function main()
    if arg[3] then
        local new_bump = verify(arg[3])
        if new_bump then
            return bump(new_bump)
        end
        return root("Could not create bump.")
    end

    local subdomain_arg = string.match(arg[2], "[a-zA-Z]*")

    if subdomain_arg == string.match(config.HOST, "[a-zA-Z]*") then
        return root()
    else
        return bump(subdomain_arg)
    end
end

print(main())

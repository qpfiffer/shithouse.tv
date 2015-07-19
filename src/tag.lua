local template = require "src/template"
local fuck_json = require "src/JSON"
local config = require "src/config"
local utils = require "src/utils"

function tag_view(tag_str)
    local f = io.open("templates/tag.html", "r")
    local rendered = template.render(f, { ["tag"] = tag_str })
    f:close()

    return rendered
end

function fuck_you(error_msg)
    local f = io.open("templates/index.html", "r")
    local rendered = template.render(f, { ["error_msg"] = error_msg })
    f:close()

    return rendered
end

function main()
    -- Fuck it, it's not a subdomain but it works.
    local tag = string.match(arg[2], utils.subdomain_match)

    if not tag or tag == "" then
        return fuck_you("no")
    end

    -- HOORAY SANITY
    return tag_view(tag)
end

print(main())

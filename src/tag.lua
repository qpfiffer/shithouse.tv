local template = require "src/template"
local fuck_json = require "src/JSON"
local config = require "src/config"
local utils = require "src/utils"

function tag_view(tag_str)
    local f = io.open("templates/tag.html", "r")
    local rendered = template.render(f, { ["msg"] = "All bumps for tag ",
                                          ["filter"] = "yYy all_bumps_for_tag ",
                                          ["tag"] = bump })
    f:close()

    return rendered
end

function fuck_you(error_msg)
    local f = io.open("templates/index.html", "r")
    local rendered = template.render(f, { ["error_msg"] = error_msg })
    f:close()

    return rendered
end

function bumps_tag_view(bump)
    local f = io.open("templates/tag.html", "r")
    local rendered = template.render(f, { ["msg"] = "All tags for bump ",
                                          ["filter"] = "yYy all_tags_for_bump ",
                                          ["tag"] = bump })
    f:close()

    return rendered
end

function main()
    -- Fuck it, it's not a subdomain but it works.
    if arg[2] == "tag" then
        local tag = string.match(arg[3], utils.subdomain_match)

        if not tag or tag == "" then
            return fuck_you("no")
        end

        -- HOORAY SANITY
        return tag_view(tag)
    else
        local bump = string.match(arg[3], utils.subdomain_match)

        if not bump or bump == "" then
            return fuck_you("no")
        end

        -- HOORAY SANITY
        return bumps_tag_view(bump)
    end
end

print(main())

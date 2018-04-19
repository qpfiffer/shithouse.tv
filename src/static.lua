local config = require "src/config"
local utils = require "src/utils"
local fuck_json = require "src/JSON"

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function attempt_read_static_file(filename)
    if filename == nil then
        return false
    end

    local whitelist = {
        "pickles.png",
        "bullens.png",
        "unreg.jpg",
        "bg1.jpg",
        "bg2.jpg",
        "bg3.jpg",
        "bg4.jpg",
        "bg5.jpg",
        "skele1.gif",
        "skele2.gif",
        "skele3.gif",
        "skele4.gif",
        "skele5.gif",
        "skele6.gif",
        "skele7.gif",
        "w95border.png",
        "295close.png",
        "sh-banner.gif",
        "sh-nsfw-new.gif"
    }


    if has_value(whitelist, filename) then
        local f = io.open("./coolpics/" .. filename)

        if f == nil then
            return false
        end

        print(f:read("*all"))
        f:close()
        return true
    end

    return false
end

function static(uri)
    local filename = utils.get_file_name_from_path(uri)
    local subdomain_arg = string.match(arg[2], utils.subdomain_match)
    local meta_data = utils.check_for_bump(subdomain_arg)

    if attempt_read_static_file(filename) == true then
        return
    end

    if not meta_data then
        return utils.error404()
    end

    -- TODO: Search through metadata for assoc. files and return the one
    -- requested, otherwise 404.
    local decoded = fuck_json:decode(meta_data:read("*all"))
    meta_data:close()
    if filename == decoded["image"] or filename == decoded["webm"] or filename == decoded["imageRepeat"] then
        local path = utils.build_bump_path(subdomain_arg)
        local f = assert(io.open(path .. "/" .. filename))
        print(f:read("*all"))
        f:close()
        return
    end
    return utils.error404()
end

print(static(arg[3]))

local Static = {}
Static.__index = Static

local config = require("src/config")
local fuck_json = require("src/JSON")

local Utils = require("src/Utils")
local Response = require("src/Response")

function Static:init(host, path)
    init = {
        host = host,
        path = path,
    }

    setmetatable(init, self)
    self.__index = self
    return init
end

function Static:_has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function Static:_get_ctype_from_filename(filename)
    local ctype = "application/octet-stream"
    local lowered = string.lower(filename)

    if lowered:match(".jpg$") or lowered:match(".jpeg$") then
        ctype = "image/jpeg"
    elseif lowered:match(".gif$") then
        ctype = "image/gif"
    elseif lowered:match(".png$") then
        ctype = "image/png"
    elseif lowered:match(".webm$") then
        ctype = "video/webm"
    end

    return ctype
end

function Static:_attempt_read_static_file(filename)
    if not filename then
        return nil
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


    if self:_has_value(whitelist, filename) then
        local f = io.open("./coolpics/" .. filename, "rb")

        if not f then
            return nil
        end

        local bytes = f:read("*all")
        local siz = f:seek("end")
        f:close()

        return Response:init(bytes, 200, self:_get_ctype_from_filename(filename), siz)
    end

    return nil
end

function Static:get(request, file)
    local filename = Utils.get_file_name_from_path(request.path)
    local subdomain_arg = request:get_subdomain()
    local meta_data = Utils.check_for_bump(subdomain_arg)

    local static_file_in_mem = self:_attempt_read_static_file(filename)
    if static_file_in_mem then
        return static_file_in_mem
    end

    if not meta_data then
        return Utils.error404()
    end

    -- TODO: Search through metadata for assoc. files and return the one
    -- requested, otherwise 404.
    local decoded = fuck_json.decode(meta_data:read("*all"))
    meta_data:close()
    if filename == decoded["image"] or filename == decoded["webm"] or filename == decoded["imageRepeat"] then
        local path = Utils.build_bump_path(subdomain_arg)
        local f = assert(io.open(path .. "/" .. filename))
        local bytes = f:read("*all")
        local siz = f:seek("end")
        f:close()
        return Response:init(bytes, 200, self:_get_ctype_from_filename(filename), siz)
    end
    return Utils.error404()
end

return Static

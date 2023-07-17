local BumpTag = {}
BumpTag.__index = BumpTag

local config = require("src/config")
local fuck_json = require("src/JSON")
local Utils = require("src/Utils")
local Template = require("src/Template")

local Root = require("src/views/Root")

local Response = require("src/Response")

function BumpTag:init(host, path)
    init = {
        host = host,
        path = path,
    }

    setmetatable(init, self)
    self.__index = self
    return init
end

function BumpTag:_fuck_you(request, error_msg)
    return Root:init():get(request, error_msg)
end

function BumpTag:get(request, errmsg)
    local tag = request.path:match(Utils.subdomain_match .. "$")
    if not tag or tag == "" then
        return self:_fuck_you(request, "no")
    end

    local f = assert(io.open("templates/tag.html", "r"))
    local rendered = Template.render(f, { ["msg"] = "All tags for bump ",
                                          ["filter"] = "yYy all_tags_for_bump ",
                                          ["tag"] = tag,
                                          ["from_bump"] = true })
    f:close()

    return Response:init(rendered, 200)
end

function BumpTag:post(request)
    local bump = request.path:match(Utils.subdomain_match .. "$")
    local decoded = fuck_json.decode(request.post_data_json)
    print (decoded, request.post_data_json)
    -- Do tags last, because we know we'll probably actually
    -- succeed in making this bump.
    local v_tags = decoded["tags"]
    if not v_tags or not bump then
        return self:get(request, "FIX YOUR FUCKIN INPUTS")
    end

    local md = Utils.check_for_bump(bump)
    if not md then
        md:close()
        return self:get(request, "WHERE'S THE FUCKIN BUMP, SHITHEAD")
    end
    local decoded_md = fuck_json.decode(md:read())
    local tag_set = {}

    local decoded_tags = decoded_md["tags"]
    if not decoded_tags then
        decoded_tags = {}
        decoded_md["tags"] = decoded_tags
    end

    for k, tag in pairs(decoded_tags) do
        tag_set[tag] = true
    end

    local new_tags = {}
    for tag in string.gmatch(v_tags, '([^,]+)') do
        -- only add tags that aren't duplicated
        if not tag_set[tag] then
            -- WOW WE ACTUALLY USE mkdir. lol.
            -- CREATE THE DIRECTORY THAT THIS TAG IS
            local tag_dir = Utils.build_tag_path(tag)
            local mkdir_output = io.popen("mkdir -p " .. tag_dir)
            mkdir_output:flush()
            mkdir_output:read("*all")
            mkdir_output:close()

            decoded_tags[#decoded_tags + 1] = tag
            new_tags[#new_tags + 1] = tag
        end
    end

    -- Encode verified data and write to disk
    local new_md = fuck_json.encode(decoded_md)
    if not new_md then
        return self:get(request, "Could not encode metadata.")
    end

    -- Write metadata to metadata file
    local bump_dir = Utils.build_bump_path(bump)
    local md_filename = bump_dir .. "/" .. config.MD_NAME
    --local md_filename = "/tmp/" .. config.MD_NAME
    local lowered = string.lower(bump)
    local meta_data = io.open(Utils.build_bump_path(lowered) .. "/" .. config.MD_NAME, "w")
    if not meta_data then
        return self:get(request, "Could not open metadata in " .. md_filename)
    end

    meta_data:write(new_md)
    meta_data:close()

    -- FUCK YOUUUU
    for k, v in pairs(new_tags) do
        -- Symlink everything in now.
        local pwd_output = io.popen("pwd")
        pwd_output:flush()
        local REAL_OUTPUT = string.gsub(pwd_output:read("*all"), "\n", "")
        pwd_output:close()

        local bump_path = Utils.build_bump_path(bump)
        local tag_dir = Utils.build_tag_path(v)
        -- BEAUTIFUL
        local ln_output = io.popen("ln -s " .. REAL_OUTPUT .. "/" .. bump_path .. " " .. REAL_OUTPUT .. "/" .. tag_dir .. "/" .. bump)
        ln_output:flush()
        ln_output:read("*all")
        ln_output:close()
        -- SUCCESS, PROBABLY
    end
    return self:get(request)
end

return BumpTag

local Root = {}
Root.__index = Root

local config = require("src/config")
local fuck_json = require("src/JSON")
local Utils = require("src/Utils")
local Template = require("src/Template")

local Response = require("src/Response")

function Root:init(host, path)
    init = {
        host = host,
        path = path,
    }

    setmetatable(init, self)
    self.__index = self
    return init
end

function Root:post(request)
    local decoded = fuck_json:decode(request.post_data_json)
    local v_subdomain = string.lower(decoded["subdomain"]:match(Utils.subdomain_match))
    local verified = {}

    -- 0. Verify Data
    -- Check for an okay name
    if not v_subdomain or v_subdomain == "" then
        return self:get(request, "You need subdomain")
    end

    -- Check to see if it already exists
    local meta_data = Utils.check_for_bump(v_subdomain)
    if meta_data then
        meta_data:close()
        return self:get(request, "Bump already exists")
    end
    verified["subdomain"] = v_subdomain

    -- Make sure that the bg-color is okay
    local v_bgcolor = decoded["bg-color"]:match("([a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9])")
        if not v_bgcolor then
            return Root:get("Pick better background color pls")
        end
        verified["bg-color"] = v_bgcolor

        -- Make sure there is at least an image
        local v_image = decoded["image"]
        if not v_image then
            return root("You need image")
        end

        -- Create bump dir
        local bump_dir = Utils.build_bump_path(v_subdomain)
        local mkdir_output = io.popen("mkdir -p " .. bump_dir)
        mkdir_output:read("*all")
        mkdir_output:close()

        local image_name = Utils.get_file_name_from_path(v_image)
        io.popen("mv " .. v_image .. " " .. bump_dir .. "/" .. image_name)
        io.close()
        if string.match(image_name,"[a-zA-Z0-9]*.webm$") then
            verified["webm"] = Utils.get_file_name_from_path(bump_dir .. "/" .. image_name)
        else
            verified["image"] = Utils.get_file_name_from_path(bump_dir .. "/" .. image_name)
        end

        local v_music = decoded["music"]
        if v_music and v_music ~= "" then
            local music_name = Utils.get_file_name_from_path(v_music)
            local out_name = bump_dir .. "/" .. music_name
            -- Truncate music to keep the size down.
            io.popen("ffmpeg -i " .. v_music .. " -t " .. config.TRUNCATE_LENGTH_S .. "s " .. out_name)
            io.close()
            verified["music"] = Utils.get_file_name_from_path(out_name)
        end

        local v_imageRepeat = decoded["imageRepeat"]
        if v_imageRepeat then
            verified["imageRepeat"] = verified["image"]
            -- Remove the image because we want one or the other.
            verified["image"] = nil
        end

        local v_text = decoded["text"]:match("[a-zA-Z0-9 '\"-]*")
        if v_text then
            verified["text"] = v_text
        end

        local v_pickles = decoded["pickles"]
        if v_pickles then
            verified["pickles"] = "true"
        end

        local v_bullens = decoded["bullens"]
        if v_bullens then
            verified["bullens"] = "true"
        end

        local v_skelly = decoded["skelly"]
        if v_skelly then
            verified["skelly"] = "true"
        end

        local v_unreg = decoded["unreg"]
        if v_unreg then
            verified["unreg"] = "true"
        end

        local v_nsfw = decoded["nsfw"]
        if v_nsfw then
            verified["nsfw"] = true
        end

    -- Do tags last, because we know we'll probably actually
    -- succeed in making this bump.
    local v_tags = decoded["tags"]
    if v_tags then
        i = 0
        tags = {}
        for tag in string.gmatch(v_tags, '([^,]+)') do
            -- WOW WE ACTUALLY USE mkdir. lol.
            -- CREATE THE DIRECTORY THAT THIS TAG IS
            local tag_dir = Utils.build_tag_path(tag)
            local mkdir_output = io.popen("mkdir -p " .. tag_dir)
            mkdir_output:read("*all")
            mkdir_output:close()

            tags[string.format("%i", i)] = tag
            i = i + 1
        end
        verified["tags"] = tags
    end

    -- Encode verified data and write to disk
    local e_verified = fuck_json:encode(verified)
    if not e_verified then
        return self:get(request, "Could not encode metadata.")
    end

    -- Write metadata to metadata file
    local md_filename = bump_dir .. "/" .. config.MD_NAME
    --local md_filename = "/tmp/" .. config.MD_NAME
    local meta_data = io.open(md_filename, "w")
    if not meta_data then
        return root("Could not open metadata in " .. md_filename)
    end
    meta_data:write(e_verified)
    meta_data:close()

    -- FUCK YOUUUU
    for k, v in pairs(verified["tags"]) do
        -- Symlink everything in now.
        local pwd_output = io.popen("pwd")
        local REAL_OUTPUT = string.gsub(pwd_output:read("*all"), "\n", "")
        pwd_output:close()

        local bump_path = Utils.build_bump_path(v_subdomain)
        local tag_dir = Utils.build_tag_path(v)
        -- BEAUTIFUL
        local ln_output = io.popen("ln -s " .. REAL_OUTPUT .. "/" .. bump_path .. " " .. REAL_OUTPUT .. "/" .. tag_dir .. "/" .. v_subdomain)
        ln_output:read("*all")
        ln_output:close()
        -- SUCCESS, PROBABLY
    end

    -- Render the newly created bump.
    return self:get("Good job. Bump " .. v_subdomain .. " created.")
end

function Root:get(request, errmsg)
    local f = io.open("templates/index.html", "r")
    local ctext = {
        ["api_url"] = config.API_URL,
        ["host"] = config.HOST,
        ["error_msg"] = errmsg
    }
    local rendered = Template.render(f, ctext)
    f:close()

    return Response:init(rendered, 200)
end

return Root

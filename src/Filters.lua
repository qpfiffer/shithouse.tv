local Filters = {}
Filters.__index = Filters

local config = require("src/config")
local normal = [[0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!'"#$%&()*+,-./:;<=>?@[\\]^_`{|}~]]
local wide = [[０１２３４５６７８９ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ！＇゛＃＄％＆（）＊＋、ー。／：；〈＝〉？＠［［］］＾＿゛｛｜｝]]
local Utils = require("src/Utils")
local fuck_json = require("src/JSON")

--filters_module.filter_pattern = "yYy ([a-zA-Z]*) ([a-zA-Z ?:']*) yYy"
Filters.filter_pattern = "yYy ([a-zA-Z_]*) (.*) yYy"
math.randomseed(os.time())

function Filters.randomfromargs(text, ctext)
    local arr = {}
    local i = 1

    for x in string.gmatch(text, "%S+") do
        arr[i] = x
        i = i + 1
    end

    return arr[math.random(#arr)]
end

function Filters.fullwidth(text, ctext)
    local new_str = ""

    for c in text:gmatch(".") do
        local idx = string.find(normal, c, 1, true)
        if idx ~= nil then
            local wide_idx = (idx * 3) - 3
            new_str = new_str .. wide:sub(wide_idx + 1, wide_idx + 3)
        else
            new_str = new_str .. c
        end
    end

    return new_str
end

function Filters.all_bumps_for_tag(tag, ctext)
    local to_return = {}
    local fixed, what = string.gsub(tag, " ", "")
    local all_bumps = io.popen("ls -clt " .. config.TAGS .. "/" .. fixed .. " | awk '{print $9}' | grep -v '^$'")
    all_bumps:flush()
    for line in all_bumps:lines() do
        to_return[#to_return + 1] = "<li><a href=\"//"
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "."
        to_return[#to_return + 1] = config.HOST
        to_return[#to_return + 1] = "/\">"
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "</a></li>"
    end

    all_bumps:close()
    return table.concat(to_return)
end

function Filters.all_tags_for_bump(bump, ctext)
    local fixed, what = string.gsub(bump, " ", "")
    local meta_data = Utils.check_for_bump(fixed)

    if not meta_data then
        return fixed
    end

    local ctext = fuck_json.decode(meta_data:read("*all"))

    local to_return = {}
    if not ctext["tags"] then
        meta_data:close()
        return " "
    end

    for dont_care, tag in pairs(ctext["tags"]) do
        to_return[#to_return + 1] = "<li><a href=\"//"
        to_return[#to_return + 1] = config.HOST
        to_return[#to_return + 1] = "/bumps_with_tag/"
        to_return[#to_return + 1] = tag
        to_return[#to_return + 1] = "\">"
        to_return[#to_return + 1] = tag
        to_return[#to_return + 1] = "</a></li>"
    end

    meta_data:close()

    return table.concat(to_return)
end

function Filters.all_bumps(text, ctext)
    local to_return = {}
    -- Held together with bash, sweet jams and summer dreams.
    local all_bumps = io.popen("ls -lt " .. config.BUMPS .. " | awk '{print $9}' | grep -v '^$'")
    all_bumps:flush()
    for line in all_bumps:lines() do
        local meta_data = Utils.check_for_bump(line)
        local is_nsfw = false

        if meta_data then
            local ctext = fuck_json.decode(meta_data:read("*all"))
            if ctext["nsfw"] then
                is_nsfw = ctext["nsfw"]
            end
            meta_data:close()
        end

        if is_nsfw then
            -- to_return[#to_return + 1] = "<li><i class=\"nsfw small-rainbow\">&nbsp;</i><a href=\"//"
            to_return[#to_return + 1] = "<li><img class=\"nsfw_gif\" src=\"sh-nsfw-new.gif\"></img><a href=\"//"
        else
            to_return[#to_return + 1] = "<li><a href=\"//"
        end
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "."
        to_return[#to_return + 1] = config.HOST
        to_return[#to_return + 1] = "/\">"
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "</a><a class=\"tags\" href=\"//"
        to_return[#to_return + 1] = config.HOST
        to_return[#to_return + 1] = "/tag/"
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "\"> TAGS &raquo;</a></li>"
    end

    all_bumps:close()
    return table.concat(to_return)
end

local bump_cache = {}
function Filters.all_bumps_json(text, ctext)
    local to_return = {}
    local first = true
    -- Held together with bash, sweet jams and summer dreams.
    local all_bumps = io.popen("ls -clt " .. config.BUMPS .. " | awk '{print $9}' | grep -v '^$'")
    all_bumps:flush()
    if not all_bumps then
        -- Not sure why this is ever nil, but here we are.
        return ""
    end

    for line in all_bumps:lines() do
        local meta_data = Utils.check_for_bump(line)
        local obj = {}

        local is_nsfw = false
        local text = ""
        local video = ""
        local image = ""

        if bump_cache[line] then
            local cached_bump = bump_cache[line]
            text = cached_bump["text"]
            is_nsfw = cached_bump["is_nsfw"]
            video = cached_bump["video"]
            image = cached_bump["image"]
        elseif meta_data then
            local ctext = fuck_json.decode(meta_data:read("*all"))
            bump_cache[line] = {text = "", is_nsfw = false, video = "", image = ""}
            if ctext["nsfw"] then
                is_nsfw = ctext["nsfw"]
                bump_cache[line]["nsfw"] = is_nsfw
            end
            if ctext["text"] then
                text = ctext["text"]
                bump_cache[line]["text"] = text
            end
            if ctext["webm"] then
                video = ctext["webm"]
                bump_cache[line]["video"] = video
            end
            if ctext["image"] then
                image = ctext["image"]
                bump_cache[line]["image"] = image
            elseif ctext["imageRepeat"] then
                image = ctext["imageRepeat"]
                bump_cache[line]["image"] = image
            end
            meta_data:close()
        end

        if not first then
            to_return[#to_return + 1] = ", "
        else
            first = false
        end

        if is_nsfw then
            to_return[#to_return + 1] = "{ \"nsfw\": true, \"name\": \""
        else
            to_return[#to_return + 1] = "{ \"nsfw\": false, \"name\": \""
        end
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "\", \"text\": \""
        to_return[#to_return + 1] = string.gsub(text, "\"", "\\\"")
        to_return[#to_return + 1] = "\", \"video\": \""
        to_return[#to_return + 1] = string.gsub(video, "\"", "\\\"")
        to_return[#to_return + 1] = "\", \"image\": \""
        to_return[#to_return + 1] = string.gsub(image, "\"", "\\\"")
        to_return[#to_return + 1] = "\"}"
    end

    all_bumps:close()
    return table.concat(to_return)
end

-------------------------------------------------------------------------------
--         __  __         __  __      __                          __  __
--    __  _\ \/ /_  __   / / / /___  / /   ___  __________   __  _\ \/ /_  __
--   / / / /\  / / / /  / / / / __ \/ /   / _ \/ ___/ ___/  / / / /\  / / / /
--  / /_/ / / / /_/ /  / /_/ / / / / /___/  __(__  |__  )  / /_/ / / / /_/ /
--  \__, / /_/\__, /   \____/_/ /_/_____/\___/____/____/   \__, / /_/\__, /
-- /____/    /____/                                       /____/    /____/
--
-------------------------------------------------------------------------------
--
-- "Unless" filter for Lua GRESHUNKEL
-- Copyright (C) 1606 William Shakespeare. All rights reserved
--
-- Inspired by the perl "unless" operator, which means "if not".
-- There's no "if" filter, "unless not" should be used instead.
--
-- Usage:
--
--   <a href="/logout">Logout</a> yYy unless not logged_in yYy
--
-- To repeat the same condition across several lines, the ~same~ variable
-- can be used like this:
--
--   <ul class="actions-bar"> yYy unless patient yYy
--       <li>Patient overview</li> xXx ~same~ xXx
--       <li>Medicine supply management</li> xXx ~same~ xXx
--       <li>Download MRI scans</li> xXx ~same~ xXx
--   </ul> xXx ~same~ xXx
--
function Filters.unless(text, ctext)
    local negation = true
    text = string.gsub(text, "^not ", function() negation = false; return ""; end)
    local existence = ctext[text] ~= nil

    if existence == negation then
        ctext['~line~'] = ''
        ctext['~same~'] = nil
    else
        ctext['~same~'] = ""
    end
    return ""
end

return Filters

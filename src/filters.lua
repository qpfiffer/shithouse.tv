local config = require "src/config"
local filters_module = {}
local normal = [[0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&()*+,-./:;<=>?@[\\]^_`{|}~]]
local wide = [[０１２３４５６７８９ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ！゛＃＄％＆（）＊＋、ー。／：；〈＝〉？＠［［］］＾＿゛｛｜｝]]

--filters_module.filter_pattern = "yYy ([a-zA-Z]*) ([a-zA-Z ?:']*) yYy"
filters_module.filter_pattern = "yYy ([a-zA-Z_]*) (.*) yYy"

function filters_module.fullwidth(text)
    local new_str = ""

    for c in text:gmatch(".") do
        local idx = string.find(normal, c)
        if idx ~= nil then
            local wide_idx = (idx * 3) - 3
            new_str = new_str .. wide:sub(wide_idx + 1, wide_idx + 3)
        else
            new_str = new_str .. c
        end
    end

    return new_str
end

function filters_module.all_bumps(text)
    local to_return = {}
    -- Held together with bash, sweet jams and summer dreams.
    local all_bumps = io.popen("ls -clt " .. config.BUMPS .. " | awk '{print $9}' | grep -v '^$'")
    for line in all_bumps:lines() do
        to_return[#to_return + 1] = "<li><a href=\"http://"
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "."
        to_return[#to_return + 1] = config.HOST
        to_return[#to_return + 1] = "/\">"
        to_return[#to_return + 1] = line
        to_return[#to_return + 1] = "</li>"
    end

    return table.concat(to_return)
end

return filters_module

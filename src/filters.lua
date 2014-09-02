local filters_module = {}
local normal = [[0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&()*+,-./:;<=>?@[\\]^_`{|}~]]
local wide = [[０１２３４５６７８９ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ！゛＃＄％＆（）＊＋、ー。／：；〈＝〉？＠［\\］＾＿‘｛｜｝"]]

--filters_module.filter_pattern = "yYy ([a-zA-Z]*) ([a-zA-Z ?:']*) yYy"
filters_module.filter_pattern = "yYy ([a-zA-Z]*) (.*) yYy"

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

return filters_module

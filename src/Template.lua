local Template = {}

-- This needs to be global for apply_filter_to_line to work:
Filters = require("src/Filters")
local sub_pattern = "xXx ([^ ]*) xXx"

function Template._apply_filter_to_line(line, ctext)
    filter, text = string.match(line, Filters.filter_pattern)
    if filter ~= nil then
        ctext['~line~'] = line
        local filter_func_name = 'Filters.' .. filter
        local results = assert(loadstring('return '.. filter_func_name ..'(...)'))(text, ctext)

        subbed = string.gsub(ctext['~line~'], "yYy .* yYy", results)
        return subbed
    end

    return line
end

function Template._apply_substitution_to_line(line, ctext)
    local perish = false
    local new_line = string.gsub(line, sub_pattern, function(match)
        perish = perish or (ctext[match] == nil)
        return ctext[match]
    end)
    return not perish and new_line or ""
end

function Template.render(file, ctext)
    local lines = {}

    ctext['~lines~'] = lines
    ctext['~file~'] = file

    for line in file:lines() do
        local new_str = Template._apply_filter_to_line(Template._apply_substitution_to_line(line, ctext), ctext)
        lines[#lines + 1] = new_str
    end

    return table.concat(lines, "\n")
end

return Template

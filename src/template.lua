filters = require "src/filters"
local template_module = {}
local sub_pattern = "xXx ([^ ]*) xXx"

function apply_filter_to_line(line, ctext)
    filter, text = string.match(line, filters.filter_pattern)
    if filter ~= nil then
        ctext['~line~'] = line
        local filter_func_name = 'filters.' .. filter
        local results = assert(loadstring('return '.. filter_func_name ..'(...)'))(text, ctext)

        subbed = string.gsub(ctext['~line~'], "yYy .* yYy", results)
        return subbed
    end

    return line
end

function apply_substitution_to_line(line, ctext)
    local perish = false
    line = string.gsub(line, sub_pattern, function(match)
        perish = perish or (ctext[match] == nil)
        return ctext[match]
    end)
    return not perish and line or ""
end

function template_module.render(file, ctext)
    local lines = {}

    ctext['~lines~'] = lines
    ctext['~file~'] = file

    for line in file:lines() do
        local new_str = apply_filter_to_line(apply_substitution_to_line(line, ctext), ctext)
        lines[#lines + 1] = new_str
    end

    return table.concat(lines, "\n")
end

return template_module

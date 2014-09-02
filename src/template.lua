filters = require "src/filters"
local template_module = {}
local sub_pattern = "xXx (.*) xXx"

function apply_filter_to_line(line)
    filter, text = string.match(line, filters.filter_pattern)
    if filter ~= nil then
        local filter_func_name = 'filters.' .. filter
        local results = assert(loadstring('return '.. filter_func_name ..'(...)'))(text)

        subbed = string.gsub(line, "yYy .* yYy", results)
        return subbed
    end

    return line
end

function apply_substitution_to_line(line, ctext)
    local match = string.match(line, sub_pattern)
    if match ~= nil and ctext[match] ~= nil then
        subbed = string.gsub(line, "xXx .* xXx", ctext[match])
        return subbed
    elseif match ~= nil then
        return ""
    end
    return line
end

function template_module.render(file, ctext)
    local lines = ""

    for line in file:lines() do
        local new_str = apply_filter_to_line(apply_substitution_to_line(line, ctext))
        lines = lines .. new_str
    end

    return lines
end

return template_module

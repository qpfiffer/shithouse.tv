filters = require "src/filters"
local template_module = {}

function apply_filter_to_line(line)
    filter, text = string.match(line, filters.filter_pattern)
    if filter ~= nil then
        local filter_func_name = 'filters.' .. filter
        local results = assert(loadstring('return '.. filter_func_name ..'(...)'))(text)

        subbed = string.gsub(line, "yYy .* yYy", results)
        return subbed
    else
        return line
    end
end

function template_module.render(file, ctext)
    local lines = ""

    for line in file:lines() do
        local new_str = apply_filter_to_line(line)
        lines = lines .. new_str
    end

    return lines
end

return template_module

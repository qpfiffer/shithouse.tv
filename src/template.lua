local filters = require "src/filters"
local template_module = {}

function template_module.render(file)
    local lines = ""

    for line in file:lines() do
        filter, text = string.match(line, filters.filter_pattern)
        if filter ~= nil then
            subbed = string.gsub(line, "yYy .* yYy", text)
            lines = lines .. subbed
        else
            lines = lines .. line
        end
    end

    return lines
end

return template_module

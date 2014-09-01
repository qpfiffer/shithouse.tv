local filters_module = {}

filters_module.filter_pattern = "yYy ([a-zA-Z]*) (.*) yYy"

function filters_module.fullwidth(text)
    return text
end

return filters_module

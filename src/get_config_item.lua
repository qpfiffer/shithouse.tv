local config = require "src/config"

function get_config_item(to_fetch)
    return config[to_fetch]
end

print(get_config_item(arg[2]))

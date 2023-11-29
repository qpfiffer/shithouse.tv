local config_module = {}

local HOST = "shithouse.tv"
if os.getenv("SHITHOUSE_HOST") then
    HOST = os.getenv("SHITHOUSE_HOST")
end

local API_URL = "api.shithouse.tv"
if os.getenv("SHITHOUSE_API_URL") then
    API_URL = os.getenv("SHITHOUSE_API_URL")
end

config_module["HOST"] = HOST
config_module["API_URL"] = API_URL
config_module["TAGS"] = "./tags"
config_module["BUMPS"] = "./tv"
config_module["MD_NAME"] = "meta.json"
config_module["TRUNCATE_LENGTH_S"] = "20"

return config_module

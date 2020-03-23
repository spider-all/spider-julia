using JSON

function getConfig()::Dict{String, String}
    return JSON.parsefile("config.json")
end

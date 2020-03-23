import HTTP
import JSON

import SQLite

include("constants.jl")
include("config.jl")
include("database.jl")

function request(url::String, requestType::RequestType, token::String, database::SQLite.DB)
    headers = [
        "Authorization" => "Bearer $token",
        "Accept" => "application/json",
        "Host" => HOST,
        "User-Agent" => USERAGENT,
        "Time-Zone" => TIMEZONE,
    ]

    response = HTTP.get(url, headers)
    content = JSON.parse(String(response.body))

    if requestType == TypeUserinfo
        user = User(get(content, "id", 0), get(content, "login", ""))
        SQLiteCreateUser(database, user)
    elseif requestType == TypeFollowing || requestType == TypeFollowers
        for con in content
            user = User(get(con, "id", 0), get(con, "login", ""))
            SQLiteCreateUser(database, user)
        end
        link = headerLink(response.headers)
        if link != ""
            sleep(3)
            request(link, requestType, token, database)
        end
    end
end

function headerLink(headers::Array{Pair{SubString{String},SubString{String}},1})::String
    for head in headers
        if head.first == "Link"
            for str in split(head.second, ", ")
                s = split(str, "; ")
                if s[2] == "rel=\"next\""
                    return replace(s[1], r"[<>]" => "")
                end
            end
        end
    end
    return ""
end

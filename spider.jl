include("constants.jl")
include("database.jl")
include("http.jl")

if !isinteractive()
    println("spider is running...")

    database = SQLiteInitialize()
    config = JSON.parsefile("config.json")
    const ENTRY = get(config, "entry", "")
    const TOKEN = get(config, "token", "")
    request("https://$HOST/users/$ENTRY", TypeUserinfo, TOKEN, database)
    while true
        logins = SQLiteGet(database)
        for login in logins
            request("https://$HOST/users/$login/followers", TypeFollowing, TOKEN, database)
            request("https://$HOST/users/$login/following", TypeFollowers, TOKEN, database)
            sleep(5)
        end
    end
end

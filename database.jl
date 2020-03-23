import SQLite
import DBInterface

include("table.jl")

const TableUserSQL = """CREATE TABLE IF NOT EXISTS `users` (
    id INTEGER PRIMARY KEY,
    login TEXT NOT NULL
)"""

const databaseFile = "spider.db"

function SQLiteInitialize()::SQLite.DB
    database = SQLite.DB(databaseFile)
    SQLite.execute(database, TableUserSQL)
    return database
end

function SQLiteCreateUser(database::SQLite.DB, user::User)
    println(user)
    try
        SQLite.execute(database, "INSERT OR REPLACE INTO `users` (`id`, `login`) VALUES ($(user.id), \"$(user.login)\")")
    catch e
        println(e)
    end
end

function SQLiteGet(database::SQLite.DB)::Array{String, 1}
    result = String[]
    rows = DBInterface.execute(database::SQLite.DB, "SELECT `login` FROM `users` ORDER BY random() limit 100")
    for row in rows
        push!(result, row.login)
    end
    return result
end

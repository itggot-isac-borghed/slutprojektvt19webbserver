def login(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    password = db.execute('SELECT Lösenord FROM Användare WHERE Namn=?', params["Username"])
    if password != []
        if (BCrypt::Password.new(password[0][0]) == params["Password"]) == true
            return true
        else
            return false
        end
    else
        return false
    end
end

def register(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    if params["Username"] != "" && params["Password"]
        db.execute('INSERT INTO Användare(Namn, Lösenord, Mail) VALUES (?, ?, ?)', params["Username"], BCrypt::Password.create(params["Password"]), params["Mail"])
        return true
    else
        return false
    end
end

def kategorier()
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    db.execute('SELECT * FROM Kategorier')
end

def kategori(id)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    return db.execute('SELECT Id,Titel FROM Diskussioner WHERE KatId=?', id), db.execute('SELECT * FROM Kategorier WHERE Id=?', id)
end

def diskussion(id)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    db.execute('SELECT * FROM Diskussioner WHERE Id=?', id), db.execute('SELECT * FROM Inlägg WHERE DiskId=?', id)
end
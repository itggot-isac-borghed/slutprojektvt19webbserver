def login(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    user = db.execute('SELECT Lösenord,Id FROM Användare WHERE Namn=?', params["Username"])
    if user.empty? == false
        if (BCrypt::Password.new(user[0]["Lösenord"]) == params["Password"]) == true
            session[:account], session[:id] = params["Username"], user[0]["id"]
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
    if params["Username"] != "" && params["Password"] != ""
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
    return [db.execute('SELECT Diskussioner.*, Användare.Namn FROM Diskussioner INNER JOIN Användare ON Diskussioner.ÄgarId = Användare.Id WHERE Diskussioner.Id=?', id), 
        db.execute('SELECT Inlägg.*, Användare.Namn FROM Inlägg INNER JOIN Användare ON Inlägg.ÄgarId = Användare.Id WHERE Inlägg.DiskId=?', id)]
end
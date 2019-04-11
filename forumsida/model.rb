def connect()
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    return db
end

def laddabild(params)
    if params[:file]
        filnamn = params[:file][:filename].split(".")
        filnamn[0] = SecureRandom.hex(10)
        @filename = "#{filnamn[0]}" + "." + "#{filnamn[1]}"
        file = params[:file][:tempfile]
        File.open("./public/img/#{@filename}", 'wb') do |f|
            f.write(file.read)
        end
    else
        @filename = nil
    end
    return @filename
end

def login(params)
    db = connect()
    user = db.execute('SELECT Lösenord,Id FROM Användare WHERE Namn=?', params["Username"])
    if user.empty? == false
        if (BCrypt::Password.new(user[0]["Lösenord"]) == params["Password"]) == true
            session[:account], session[:id] = params["Username"], user[0]["Id"]
            return true
        else
            return false
        end
    else
        return false
    end
end

def register(params)
    db = connect()
    if params["Username"] != "" && params["Password"] != "" && params["Mail"] != ""
        db.execute('INSERT INTO Användare(Namn, Lösenord, Mail) VALUES (?, ?, ?)', params["Username"], BCrypt::Password.create(params["Password"]), params["Mail"])
        return true
    else
        return false
    end
end

def kategorier()
    db = connect()
    db.execute('SELECT * FROM Kategorier')
end

def kategori(id)
    db = connect()
    return db.execute('SELECT Id,Titel FROM Diskussioner WHERE KatId=?', id), db.execute('SELECT * FROM Kategorier WHERE Id=?', id)
end

def skapadisk(params, userid)
    db = connect()
    @filename = laddabild(params)
    db.execute('INSERT INTO Diskussioner(ÄgarId, KatId, Titel, Info, Bild) VALUES (?, ?, ?, ?, ?)', userid, params["id"], 
        params["titel"], params["info"], @filename)
end

def diskussion(id)
    db = connect()
    return [db.execute('SELECT Diskussioner.*, Användare.Namn FROM Diskussioner INNER JOIN Användare ON Diskussioner.ÄgarId = Användare.Id WHERE Diskussioner.Id=?', id), 
        db.execute('SELECT Inlägg.*, Användare.Namn FROM Inlägg INNER JOIN Användare ON Inlägg.ÄgarId = Användare.Id WHERE Inlägg.DiskId=?', id)]
end

def redigeradisk(params, userid)
    db = connect()
    disk = db.execute('SELECT * FROM Diskussioner WHERE Id=? AND ÄgarId=?', params["id"], userid)
    if disk != []
        return disk.first
    else
        return false
    end
end

def spararedigeringdisk(params, userid)
    db = connect()
    disk = db.execute('SELECT * FROM Diskussioner WHERE Id=? AND ÄgarId=?', params["id"], userid)
    if disk == []
        return false
    else
        if params[:file]
            @filename = laddabild(params)
            db.execute('UPDATE Diskussioner SET Titel=?,Info=?,Bild=? WHERE Id=?', params["Titel"], params["Info"], @filename, params["id"])
        else
            db.execute('UPDATE Diskussioner SET Titel=?, Info=? WHERE Id=?', params["Titel"], params["Info"], params["id"])
        end
        return disk.first["Id"]
    end
end


def tabortdisk(params, userid)
    db = connect()
    disk = db.execute('SELECT ÄgarId,KatId FROM Diskussioner WHERE Id=?', params["id"]).first
    if disk.length == 0 || userid != disk["ÄgarId"]
        return false
    else
        db.execute('DELETE FROM Diskussioner WHERE Id=?', params["id"])
        db.execute('DELETE FROM Inlägg WHERE DiskId=?', params["id"])
        return disk["KatId"]
    end
end

def skapainlg(params, userid)
    db = connect()
    @filename = laddabild(params)
    db.execute('INSERT INTO Inlägg(DiskId, ÄgarId, Info, Bild) VALUES (?, ?, ?, ?)', params["id"], userid, params["info"], @filename)
end

def redigerainlg(params, userid)
    db = connect()
    inlg = db.execute('SELECT * FROM Inlägg WHERE Id=? AND ÄgarId=?', params["id"], userid)
    if inlg != []
        return inlg.first
    else
        return false
    end
end

def spararedigeringinlg(params, userid)
    db = connect()
    inlg = db.execute('SELECT * FROM Inlägg WHERE Id=? AND ÄgarId=?', params["id"], userid)
    if inlg == []
        return false
    else
        if params[:file]
            @filename = laddabild(params)
            db.execute('UPDATE Inlägg SET Info=?,Bild=? WHERE Id=?', params["Info"], @filename, params["id"])
        else
            db.execute('UPDATE Inlägg SET Info=? WHERE Id=?', params["Info"], params["id"])
        end
        return inlg.first["DiskId"]
    end
end

def tabortinlg(params, userid)
    db = connect()
    inlg = db.execute('SELECT ÄgarId,DiskId FROM Inlägg WHERE Id=?', params["id"]).first
    if userid != inlg["ÄgarId"]
        return false
    else
        db.execute('DELETE FROM Inlägg WHERE Id=?', params["id"])
        return inlg["DiskId"]
    end
end
module Model
    # Opens the database
    #
    # @return a connection to the database
    def connect()
        db = SQLite3::Database.new("db/databas.db")
        db.results_as_hash = true
        return db
    end

    # Loads an image and gives it a random name
    #
    # @param [Hash] params form data
    # @option params [Hash] :file Image information
    #
    # @return [String] the name of the file
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

    # Loads the profile of a user
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the profile
    #
    # @return [Hash] consisting of the profile content
    def profil(params)
        db = connect()
        profil = db.execute('SELECT * FROM Användare WHERE Id=?', params["id"])
        return profil.first
    end

    # Updates the profile of a user
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the profile
    # @option params [String] password The password which is to be updated
    # @option params [String] password2 The password which is used for validation
    # @option params [String] mail The email which is to be updated
    # @option params [String] username The username which is to be updated
    # @userid [Integer] The ID of the user
    #
    # @return [true]
    # @return [false] if IDs do not match or password2 does not match the user's current password
    def updateprofile(params, userid)
        db = connect()
        if params["id"] != userid
            return false
        end
        password = db.execute('SELECT Lösenord FROM Användare WHERE Id=?', userid).first
        if (BCrypt::Password.new(password["Lösenord"]) == params["password2"]) == true
            if params["password"] != ""
                db.execute('UPDATE Användare SET Lösenord=? WHERE Id=?', BCrypt::Password.create(params["password"]), userid)
            end
            if params["mail"] != ""
                db.execute('UPDATE Användare SET Mail=? WHERE Id=?', params["mail"], userid)
            end
            if params["username"] != ""
                db.execute('UPDATE Användare SET Namn=? WHERE Id=?', params["username"], userid)
            end
            return true
        else
            return false
        end
    end

    # Loads a user's saved discussions
    #
    # @userid [Integer] The ID of the user
    #
    # @return [Array] containing the discussions
    def saved(userid)
        db = connect()
        followed = db.execute('SELECT Diskussioner.Id,Diskussioner.Titel FROM Diskussioner INNER JOIN Användare_Diskussioner 
            WHERE Användare_Diskussioner.DiskId = Diskussioner.Id AND Användare_Diskussioner.AnvId = ?', userid)
        return followed
    end

    # Removes a discussion from being saved
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @userid [Integer] The ID of the user
    #
    def deletesave(params, userid)
        db = connect()
        db.execute('DELETE FROM Användare_Diskussioner WHERE AnvId=? AND DiskId=?', userid, params["id"])
    end

    # Saves a discussion to a user
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @userid [Integer] The ID of the user
    #
    def save(params, userid)
        db = connect
        db.execute('INSERT INTO Användare_Diskussioner(AnvId, DiskId) VALUES(?, ?)', userid, params["id"])
    end

    # Edits the information of a user's profile
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the profile
    # @userid [Integer] The ID of the user
    #
    def editinfo(params, userid)
        db = connect()
        db.execute('UPDATE Användare SET Info=? WHERE Id=?', params["info"], userid)
    end

    # Login a user
    #
    # @param [Hash] params form data
    # @option params [String] Username The input username
    # @option params [String] Password The input password
    #
    # @return [true]
    # @return [false] if the user doesn't exist in the database or if the credentials don't match the user
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

    # Register a user
    #
    # @param [Hash] params form data
    # @option params [String] Username The name of the user which is to be registered
    # @option params [String] Password The password of the user which is to be registered
    # @option params [String] Password2 The password of the user which is to be registered is repeated
    # @option params [String] Mail The email of the user which is to be registered
    #
    # @return true
    # @return false if the credentials weren't filled or if the user already exists
    def register(params)
        db = connect()
        if params["Username"] != "" && params["Password"] != "" && params["Mail"] != "" && params["Password"] == params["Password2"]
            if db.execute('SELECT Id FROM Användare WHERE Namn=? OR Mail=?', params["Username"], params["Mail"]) != []
                return false
            end
            db.execute('INSERT INTO Användare(Namn, Lösenord, Mail) VALUES (?, ?, ?)', params["Username"], BCrypt::Password.create(params["Password"]), params["Mail"])
            return true
        else
            return false
        end
    end

    # Load the categories in the database
    #
    # @return [Array] consisting of the categories
    def kategorier()
        db = connect()
        db.execute('SELECT * FROM Kategorier').first
    end

    # Load the discussions of a category
    #
    # @id [Integer] The ID of the category
    #
    # @return [Array] consisting of the discussions
    def kategori(id)
        db = connect()
        return db.execute('SELECT Id,Titel FROM Diskussioner WHERE KatId=?', id), db.execute('SELECT * FROM Kategorier WHERE Id=?', id)
    end

    # Creates a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the category
    # @option params [Hash] :file The image of the discussion
    # @option params [String] titel The title of the discussion
    # @option params [String] info The information of the discussion
    # @userid [Integer] The ID of the user
    #
    def skapadisk(params, userid)
        db = connect()
        @filename = laddabild(params)
        db.execute('INSERT INTO Diskussioner(ÄgarId, KatId, Titel, Info, Bild) VALUES (?, ?, ?, ?, ?)', userid, params["id"], 
            params["titel"], params["info"], @filename)
    end

    # Loads a discussion and all posts that are made in it
    #
    # @id [Integer] The ID of the discussion
    #
    # @return [Array] consisting of the discussion and the posts
    def diskussion(id)
        db = connect()
        return [db.execute('SELECT Diskussioner.*, Användare.Namn FROM Diskussioner INNER JOIN Användare ON Diskussioner.ÄgarId = Användare.Id WHERE Diskussioner.Id=?', id), 
            db.execute('SELECT Inlägg.*, Användare.Namn FROM Inlägg INNER JOIN Användare ON Inlägg.ÄgarId = Användare.Id WHERE Inlägg.DiskId=?', id)]
    end

    # Loads a discussion and checks if the user owns the discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @userid [Integer] The ID of the user
    #
    # @return [Hash]
    #   * :Id [Integer] The ID of the discussion
    #   * :ÄgarId [Integer] The ID of the owner of the discussion
    #   * :KatId [Integer] The ID of the category of the discussion
    #   * :Titel [String] The title of the discussion
    #   * :Info [String] The information of the discussion
    #   * :Bild [String] The image of the discussion
    # @return [false] if the user does not own the discussion
    def redigeradisk(params, userid)
        db = connect()
        disk = db.execute('SELECT * FROM Diskussioner WHERE Id=? AND ÄgarId=?', params["id"], userid)
        if disk != []
            return disk.first
        else
            return false
        end
    end

    # Edits a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @option params [Hash] :file The image file of the discussion
    # @option params [String] Titel The title of the discussion
    # @option params [String] Info The information about the discussion
    # @userid [Integer] The ID of the user
    #
    # @return [Integer] The ID of the discussion
    # @return [false] if the user does not own the discussion
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

    # Deletes a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @userid [Integer] The ID of the user
    #
    # @return [Integer] The ID of the discussion's category
    # @return [false] if the user does not own the discussion
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

    # Creates a post in a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @option params [String] info The information of the post
    # @option params [Hash] :file The image of the post
    # @userid [Integer] The ID of the user
    #
    def skapainlg(params, userid)
        db = connect()
        @filename = laddabild(params)
        db.execute('INSERT INTO Inlägg(DiskId, ÄgarId, Info, Bild) VALUES (?, ?, ?, ?)', params["id"], userid, params["info"], @filename)
    end

    # Loads a post and checks if the user owns the post
    #
    # @param [Hash] params form data
    # @option params [Integer] id, The ID of the post
    # @userid [Integer] The ID of the user
    #
    # @return [Hash]
    #   * :Id, The ID of the post
    #   * :DiskId, The ID of the post's discussion
    #   * :ÄgarId, The ID of the owner of the post
    #   * :Info, The information of the post
    #   * :Bild, The image of the post
    # @return [false] if the user does not own the post
    def redigerainlg(params, userid)
        db = connect()
        inlg = db.execute('SELECT * FROM Inlägg WHERE Id=? AND ÄgarId=?', params["id"], userid)
        if inlg != []
            return inlg.first
        else
            return false
        end
    end

    # Edits a post
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the post
    # @option params [Hash] :file The image of the post
    # @option params [String] Info The information of the post
    # @userid [Integer] The ID of the user
    #
    # @return [Integer] the ID of the discussion
    # @return [false] if the user does not own the post
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

    # Deletes a post
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the post
    # @userid [Integer] The ID of the user
    #
    # @return [Integer] the ID of the discussion
    # @return [false] if the user does not own the post
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
end
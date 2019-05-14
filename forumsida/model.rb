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
    def load_image(params)
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
    def load_profile(params)
        db = connect()
        profile = db.execute('SELECT * FROM users WHERE Id=?', params["id"])
        return profile.first
    end

    # Updates the profile of a user
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the profile
    # @option params [String] password The password which is to be updated
    # @option params [String] password2 The password which is used for validation
    # @option params [String] password3 Repetition of the password which is to be updated
    # @option params [String] mail The email which is to be updated
    # @option params [String] username The username which is to be updated
    # @param [Integer] userid The ID of the user
    #
    # @return [true]
    # @return [false] if IDs do not match or password2 does not match the user's current password
    def update_profile(params, userid)
        db = connect()
        if params["id"] != userid
            return false
        end
        password = db.execute('SELECT Password FROM users WHERE Id=?', userid).first
        if (BCrypt::Password.new(password["Password"]) == params["password2"]) == true
            if params["password"] != "" && params["password"] == params["password3"]
                db.execute('UPDATE users SET Password=? WHERE Id=?', BCrypt::Password.create(params["password"]), userid)
            end
            if params["mail"] != ""
                db.execute('UPDATE users SET Mail=? WHERE Id=?', params["mail"], userid)
            end
            if params["username"] != ""
                db.execute('UPDATE users SET Username=? WHERE Id=?', params["username"], userid)
            end
            return true
        else
            return false
        end
    end

    # Loads a user's saved discussions
    #
    # @param [Integer] userid The ID of the user
    #
    # @return [Array] containing the discussions
    def saved(userid)
        db = connect()
        followed = db.execute('SELECT discussions.Id,discussions.Title FROM discussions INNER JOIN users_discussions 
            WHERE users_discussions.DiscId = discussions.Id AND users_discussions.UserId = ?', userid)
        return followed
    end

    # Removes a discussion from being saved
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @param [Integer] userid The ID of the user
    #
    def delete_save(params, userid)
        db = connect()
        db.execute('DELETE FROM users_discussions WHERE UserId=? AND DiscId=?', userid, params["id"])
    end

    # Saves a discussion to a user
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @param [Integer] userid The ID of the user
    #
    def save(params, userid)
        db = connect
        db.execute('INSERT INTO users_discussions(UserId, DiscId) VALUES(?, ?)', userid, params["id"])
    end

    # Edits the information of a user's profile
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the profile
    # @param [Integer] userid The ID of the user
    #
    def edit_info(params, userid)
        db = connect()
        db.execute('UPDATE users SET Info=? WHERE Id=?', params["info"], userid)
    end

    # Login a user
    #
    # @param [Hash] params form data
    # @option params [String] Username The input username
    # @option params [String] Password The input password
    #
    # @return [true] and the users ID
    # @return [false] if the user doesn't exist in the database or if the credentials don't match the user
    def login(params)
        db = connect()
        user = db.execute('SELECT Password,Id FROM users WHERE Username=?', params["Username"])
        if user.empty? == false
            if (BCrypt::Password.new(user[0]["Password"]) == params["Password"]) == true
                return [true, user[0]["Id"]]
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
            if db.execute('SELECT Id FROM users WHERE Username=? OR Mail=?', params["Username"], params["Mail"]) != []
                return false
            end
            db.execute('INSERT INTO users(Username, Password, Mail) VALUES (?, ?, ?)', params["Username"], BCrypt::Password.create(params["Password"]), params["Mail"])
            return true
        else
            return false
        end
    end

    # Load the categories in the database
    #
    # @return [Array] consisting of the categories
    def categories()
        db = connect()
        db.execute('SELECT * FROM categories')
    end

    # Load the discussions of a category
    #
    # @param [Integer] id The ID of the category
    #
    # @return [Array] consisting of the discussions
    def category(id)
        db = connect()
        return db.execute('SELECT Id,Title FROM discussions WHERE CatId=?', id), db.execute('SELECT * FROM categories WHERE Id=?', id)
    end

    # Creates a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the category
    # @option params [Hash] :file The image of the discussion
    # @option params [String] titel The title of the discussion
    # @option params [String] info The information of the discussion
    # @param [Integer] userid The ID of the user
    #
    def create_discussion(params, userid)
        db = connect()
        @filename = load_image(params)
        db.execute('INSERT INTO discussions(UserId, CatId, Title, Info, Image) VALUES (?, ?, ?, ?, ?)', userid, params["id"], 
            params["titel"], params["info"], @filename)
    end

    # Loads a discussion and all posts that are made in it
    #
    # @param [Integer] id The ID of the discussion
    #
    # @return [Array] consisting of the discussion and the posts
    def discussion(id)
        db = connect()
        return [db.execute('SELECT discussions.*, users.Username FROM discussions INNER JOIN users ON discussions.UserId = users.Id WHERE discussions.Id=?', id), 
            db.execute('SELECT posts.*, users.Username FROM posts INNER JOIN users ON posts.userId = users.Id WHERE posts.DiscId=?', id)]
    end

    # Loads a discussion and checks if the user owns the discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @param [Integer] userid The ID of the user
    #
    # @return [Hash]
    #   * :Id [Integer] The ID of the discussion
    #   * :UserId [Integer] The ID of the owner of the discussion
    #   * :CatId [Integer] The ID of the category of the discussion
    #   * :Title [String] The title of the discussion
    #   * :Info [String] The information of the discussion
    #   * :Image [String] The image of the discussion
    # @return [false] if the user does not own the discussion
    def edit_discussion(params, userid)
        db = connect()
        disk = db.execute('SELECT * FROM discussions WHERE Id=? AND UserId=?', params["id"], userid)
        if disk != []
            return disk.first
        else
            return false
        end
    end

    # Updates a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @option params [Hash] :file The image file of the discussion
    # @option params [String] Titel The title of the discussion
    # @option params [String] Info The information about the discussion
    # @param [Integer] userid The ID of the user
    #
    # @return [Integer] The ID of the discussion
    # @return [false] if the user does not own the discussion
    def update_discussion(params, userid)
        db = connect()
        disk = db.execute('SELECT * FROM discussions WHERE Id=? AND UserId=?', params["id"], userid)
        if disk == []
            return false
        else
            if params[:file]
                @filename = load_image(params)
                db.execute('UPDATE discussions SET Title=?,Info=?,Image=? WHERE Id=?', params["Titel"], params["Info"], @filename, params["id"])
            else
                db.execute('UPDATE discussions SET Title=?, Info=? WHERE Id=?', params["Titel"], params["Info"], params["id"])
            end
            return disk.first["Id"]
        end
    end

    # Deletes a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @param [Integer] userid The ID of the user
    #
    # @return [Integer] The ID of the discussion's category
    # @return [false] if the user does not own the discussion
    def remove_discussion(params, userid)
        db = connect()
        disk = db.execute('SELECT UserId,CatId FROM discussions WHERE Id=?', params["id"]).first
        if disk.length == 0 || userid != disk["ÄgarId"]
            return false
        else
            db.execute('DELETE FROM discussions WHERE Id=?', params["id"])
            db.execute('DELETE FROM posts WHERE DiskId=?', params["id"])
            return disk["CatId"]
        end
    end

    # Creates a post in a discussion
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the discussion
    # @option params [String] info The information of the post
    # @option params [Hash] :file The image of the post
    # @param [Integer] userid The ID of the user
    #
    def create_post(params, userid)
        db = connect()
        @filename = load_image(params)
        db.execute('INSERT INTO posts(DiscId, UserId, Info, Image) VALUES (?, ?, ?, ?)', params["id"], userid, params["info"], @filename)
    end

    # Loads a post and checks if the user owns the post
    #
    # @param [Hash] params form data
    # @option params [Integer] id, The ID of the post
    # @param [Integer] userid The ID of the user
    #
    # @return [Hash]
    #   * :Id, The ID of the post
    #   * :DiskId, The ID of the post's discussion
    #   * :ÄgarId, The ID of the owner of the post
    #   * :Info, The information of the post
    #   * :Bild, The image of the post
    # @return [false] if the user does not own the post
    def edit_post(params, userid)
        db = connect()
        post = db.execute('SELECT * FROM posts WHERE Id=? AND UserId=?', params["id"], userid)
        if post != []
            return post.first
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
    # @param [Integer] userid The ID of the user
    #
    # @return [Integer] the ID of the discussion
    # @return [false] if the user does not own the post
    def update_post(params, userid)
        db = connect()
        post = db.execute('SELECT * FROM posts WHERE Id=? AND UserId=?', params["id"], userid)
        if post == []
            return false
        else
            if params[:file]
                @filename = load_image(params)
                db.execute('UPDATE posts SET Info=?,Image=? WHERE Id=?', params["Info"], @filename, params["id"])
            else
                db.execute('UPDATE posts SET Info=? WHERE Id=?', params["Info"], params["id"])
            end
            return post.first["DiscId"]
        end
    end

    # Deletes a post
    #
    # @param [Hash] params form data
    # @option params [Integer] id The ID of the post
    # @param [Integer] userid The ID of the user
    #
    # @return [Integer] the ID of the discussion
    # @return [false] if the user does not own the post
    def delete_post(params, userid)
        db = connect()
        post = db.execute('SELECT UserId,DiscId FROM posts WHERE Id=?', params["id"]).first
        if userid != post["UserId"]
            return false
        else
            db.execute('DELETE FROM posts WHERE Id=?', params["id"])
            return post["DiscId"]
        end
    end
end
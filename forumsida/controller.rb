require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require_relative 'model.rb'
enable :sessions

include Model

configure do
    set :secured_route, ["/saved", "/save/", "/users/update/", "/users/edit/", "/post/create/", "/discussion/create/", "/discussion/edit/", "/discussion/delete/", "/post/edit/", "/post/delete/"]
end

before do
    if settings.secured_route.any? { |elem| request.path.start_with?(elem)}
        if session[:account]
        else
            halt 403
        end
    end
end

# Display Landing Page
#
get('/') do 
    slim(:home)
end

# Displays a user's profile
#
# @param [Integer] :id, The ID of the profile
# @see Model#load_profile
get('/users/:id') do
    result = load_profile(params)
    slim(:profile, locals:{profile:result})
end

# Displays a page where a user can edit their profile
#
# @param [Integer] :id, The ID of the profile
# @see Model#load_profil
get('/users/edit/:id') do 
    result = load_profile(params)
    slim(:editprofile, locals:{profile:result})
end

# Updates a user's profile and redirects to '/' or displays error 403
#
# @param [Integer] :id, The ID of the profile
# @param [String] password, The password which is to be updated
# @param [String] password2, The password which is used for validation
# @param [String] mail, The email which is to be updated
# @param [String] username, The username which is to be updated
# @param [Integer] :id, The ID of the user
#
# @see Model#update_profile
post('/users/update/:id') do 
    result = update_profile(params, session[:id])
    if result == true
        redirect('/')
    else
        halt 403
    end
end

# Displays a user's saved discussions
#
# @param [Integer] :id, The ID of the user
#
# @see Model#saved
get('/saved') do 
    result = saved(session[:id])
    slim(:saved, locals:{saved:result})
end

# Removes a discussion from being saved and redirects to '/saved'
#
# @param [Integer] :id, The ID of the discussion
# @param [Integer] :id, The ID of the user
#
# @see Model#delete_save
post('/saved/delete/:id') do
    delete_save(params, session[:id])
    redirect('/saved')
end

# Saves a discussion to a user and redirects to '/discussion/:id'
#
# @param [Integer] :id, The ID of the discussion
# @param [Integer] :id, The ID of the user
#
# @see Model#save
post('/save/:id') do
    save(params, session[:id])
    redirect("/discussion/#{params["id"]}")
end

# Edits the information of a user's profile and redirects to 'users/:id' or displays error 403
#
# @param [Integer] :id, The ID of the profile
# @param [Integer] :id, The ID of the user
#
# @see Model#edit_info
post('/users/edit/:id') do 
    if params["id"].to_i != session[:id]
        halt 403
    end
    edit_info(params, session[:id])
    redirect("/users/#{params["id"]}")
end

# Display Login Page
#
get('/login') do
    slim(:login)
end

# Login a user and redirect to '/' or '/loginfail'
#
# @param [String] Username, The input username
# @param [String] Password, The input password
#
# @see Model#login
post('/login') do
    loggedin = login(params)
    if loggedin[0] == true
        session[:account], session[:id] = params["Username"], loggedin[1]
        redirect('/')
    else
        redirect('/loginfail')
    end
end

# Display Loginfail Page
get('/loginfail') do
    slim(:loginfail)
end

# Log out a user and redirect to '/'
#
# @param [String] :account, The name of the user
# @param [Integer] :userid, The ID of the user
#
post('/logout') do
    session[:account], session[:id] = nil, nil
    redirect('/')
end

# Display Signup Page
#
get('/signup') do
    slim(:signup)
end

# Register a user and redirect to '/login' or doesn't register the user and redirect to '/signup'
#
# @param [String] Username, The name of the user which is to be registered
# @param [String] Password, The password of the user which is to be registered
# @param [String] Password2, The password of the user which is to be registered is repeated
# @param [String] Mail, The email of the user which is to be registered
#
# @see Model#register
post('/signup') do
    signup = register(params)
    if signup == true
        redirect('/login')
    else
        redirect('/signup')
    end
end

# Display the categories page
#
# @see Model#categories
get('/categories') do
    cat = categories()
    slim(:categories, locals:{cats:cat})
end

# Display the discussions of a category
#
# @param [Integer] :id, The ID of the category
#
# @see Model#category
get('/categories/:id') do 
    disc, kat = category(params["id"])
    slim(:category, locals:{discs:disc, cat:kat[0]})
end

# Display the create discussions page
#
# @param [Integer] :id, The ID of the category
#
get('/discussion/create/:id') do
    slim(:createdisc, locals:{id:params["id"]})
end

# Create a discussion and redirect to it
#
# @param [Integer] :id, The ID of the category
# @param [Hash] :file, The image file of the discussion
# @param [String] titel, The title of the discussion
# @param [String] info, The information of the discussion
# @param [Integer] :id, The ID of the user
#
# @see Model#create_discussion 
post('/discussion/create/:id') do
    create_discussion(params, session[:id])
    redirect("/categories/#{params["id"]}")
end

# Display the discussion page
#
# @param [Integer] :id, The ID of the discussion
#
# @see Model#discussion
get('/discussion/:id') do
    disc = discussion(params["id"])
    post = disc[1]
    disk = disc[0]
    slim(:discussion, locals:{disc:disk[0], posts:post})
end

# Display the edit discussion page
#
# @param [Integer] :id, The ID of the discussion
# @param [Integer] :userid, The ID of the user
#
# @see Model#edit_discussion
get('/discussion/edit/:id') do
    result = edit_discussion(params, session[:id])
    if result == false
        halt 403
    else
        slim(:editdisc, locals:{disc:result})
    end
end

# Edits a discussion and redirects to '/discussion/:id' or gives error 403
#
# @param [Integer] :id, The ID of the discussion
# @param [Hash] :file, The image file of the discussion
# @param [String] Titel, The title of the discussion
# @param [String] Info, The information about the discussion
# @param [Integer] :userid, The ID of the user
#
# @see Model#update_discussion
post('/discussion/edit/:id') do
    result = update_discussion(params, session[:id])
    if result == false
        halt 403
    else
        redirect("/discussion/#{result}")
    end
end

# Deletes a discussion
#
# @param [Integer] :id, The ID of the discussion
# @param [Integer] :id, The ID of the user
#
# @see Model#remove_discussion
post('/discussion/delete/:id') do
    result = remove_discussion(params, session[:id])
    if result == false
        halt 403
    else
        redirect("/categories/#{result}")
    end
end

# Creates a post in a discussion and redirects to '/discussion/:id'
#
# @param [Integer] :id, The ID of the discussion
# @param [String] info, The information of the post
# @param [Hash] :file, The image of the post
# @param [Integer] :userid, The ID of the user
#
# @see Model#create_post
post('/post/create/:id') do
    create_post(params, session[:id])
    redirect("/discussion/#{params["id"]}")
end

# Display the edit post page or give error 403 if the user does not own the post
#
# @param [Integer] :id, The ID of the post
# @param [Integer] :userid, The ID of the user
#
# @see Model#edit_post
get('/post/edit/:id') do
    result = edit_post(params, session[:id])
    if result == false
        halt 403
    else
        slim(:editpost, locals:{post:result})
    end
end

# Edits a post and redirect to '/discussion/:id' or give error 403
#
# @param [Integer] :id, The ID of the post
# @param [Hash] :file, The image of the post
# @param [String] Info, The information of the post
# @param [Integer] :userid, The ID of the user
#
# @see Model#update_post
post('/post/edit/:id') do
    result = update_post(params, session[:id])
    if result == false
        halt 403
    else
        redirect("/discussion/#{result}")
    end
end

# Deletes a post and redirect to '/discussion/:id' or give error 403
#
# @param [Integer] :id, The ID of the post
# @param [Integer] :userid, The ID of the user
#
# @see Model#delete_post
post('/post/delete/:id') do 
    result = delete_post(params, session[:id])
    if result == false
        halt 403
    else
        redirect("/discussion/#{result}")
    end
end

error 404 do
    "Page not found"
end

error 403 do
    "Forbidden action"
end

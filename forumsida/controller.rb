require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require_relative 'model.rb'
enable :sessions

configure do
    set :secured_route, ["/logout"]
end

before do
    if settings.secured_route.any? { |elem| request.path.start_with?(elem)}
        if session[:account]
        else
            halt 403
        end
    end
end

get('/') do 
    slim(:home)
end

get('/login') do
    slim(:login)
end

post('/login') do
    loggedin = login(params)
    if loggedin == true
        session[:account] = params["Username"]
        redirect('/')
    else
        redirect('/loginfail')
    end
end

get('/loginfail') do
    slim(:loginfail)
end

post('/logout') do
    session[:account] = nil
    redirect('/')
end

get('/signup') do
    slim(:signup)
end

post('/signup') do
    signup = register(params)
    if signup == true
        redirect('/login')
    else
        redirect('/signup')
    end
end

get('/categories') do
    cat = kategorier()
    slim(:categories, locals:{cats:cat})
end

get('/categories/:id') do 
    disc, kat = kategori(params["id"])
    slim(:category, locals:{discs:disc, cat:kat[0]})
end

get('/discussion/:id') do
    posts, disk = diskussion(params["id"])
    slim(:discussion, locals:{})
end

error 404 do
    "Page not found"
end

error 403 do
    "Forbidden action"
end
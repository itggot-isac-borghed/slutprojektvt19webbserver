require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require_relative 'model.rb'
enable :sessions

configure do
    set :secured_route, ["/logout", "/newpost", "/discussion/create/:id"]
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
        redirect('/')
    else
        redirect('/loginfail')
    end
end

get('/loginfail') do
    slim(:loginfail)
end

post('/logout') do
    session[:account], session[:id] = nil, nil
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

get('/discussion/create/:id') do
    slim(:createdisc, locals:{id:params["id"]})
end

post('/discussion/create/:id') do
    skapadisk(params, session[:id])
    redirect("/categories/#{params["id"]}")
end

get('/discussion/:id') do
    diskussion = diskussion(params["id"])
    inlg = diskussion[0]
    disk = diskussion[1]
    slim(:discussion, locals:{disc:disk[0], posts:inlg})
end

error 404 do
    "Page not found"
end

error 403 do
    "Forbidden action"
end
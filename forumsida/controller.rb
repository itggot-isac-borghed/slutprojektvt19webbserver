require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require_relative 'model.rb'
enable :sessions

configure do
    set :secured_route, ["/post/create/", "/discussion/create/", "/discussion/edit/", "/discussion/delete/", "/post/edit/", "/post/delete/"]
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
    inlg = diskussion[1]
    disk = diskussion[0]
    slim(:discussion, locals:{disc:disk[0], posts:inlg})
end

get('/discussion/edit/:id') do
    result = redigeradisk(params, session[:id])
    if result == false
        halt 403
    else
        slim(:editdisc, locals:{disc:result})
    end
end

post('/discussion/edit/:id') do
    result = spararedigeringdisk(params, session[:id])
    if result == false
        halt 403
    else
        redirect("/discussion/#{result}")
    end
end

post('/discussion/delete/:id') do
    result = tabortdisk(params, session[:id])
    if result == false
        halt 403
    else
        redirect("/categories/#{result}")
    end
end

post('/post/create/:id') do
    skapainlg(params, session[:id])
    redirect("/discussion/#{params["id"]}")
end

get('/post/edit/:id') do
    result = redigerainlg(params, session[:id])
    if result == false
        halt 403
    else
        slim(:editpost, locals:{post:result})
    end
end

post('/post/edit/:id') do
    result = spararedigeringinlg(params, session[:id])
    if result == false
        halt 403
    else
        redirect("/discussion/#{result}")
    end
end

post('/post/delete/:id') do 
    result = tabortinlg(params, session[:id])
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
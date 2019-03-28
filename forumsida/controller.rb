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
        redirect('/')
    else
        redirect('/signup')
    end
end

error 404 do
    "Page not found"
end

error 403 do
    "Forbidden action"
end
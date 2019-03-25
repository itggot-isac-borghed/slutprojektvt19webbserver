require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require_relative 'model.rb'
enable :sessions

configure do
    set :secured_route, []
end

before do
    if settings.secured_route.any? { |elem| request.path.start_with?(elem)}
        if session[:account]
        else
            halt 403
        end
    end
end

error 404 do
    "Page not found"
end

error 403 do
    "Forbidden action"
end
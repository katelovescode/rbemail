require 'sinatra'
require 'pony'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
  erb :email_form
end

post '/' do
  Pony.mail({
    :to => "info@misdepartment.com",
    :from => params[:email],
    :subject => "Inquiry from MIS Department website",
    :body => "From: " + params[:name] + "
    Message: " + params[:body],
    :via => :smtp
    })
  redirect '/success'
end

get '/success' do
  erb :index
end

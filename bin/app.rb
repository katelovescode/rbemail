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

  name = params[:name]
  email = params[:email]
  body = params[:body]
  nerror = ""
  eerror = ""
  berror = ""

  if name == ""
    nerror = "Please enter your name."
  elsif email == ""
    eerror = "Please enter your email address."
  elsif body == ""
    berror = "Please enter a message."
  end

  if !(name == "" || email == "" || body == "")
    Pony.mail({
      :to => "info@misdepartment.com",
      :from => email,
      :subject => "Inquiry from MIS Department website",
      :body => "From: " + name + "
      Message: " + body,
      :via => :smtp
      })
    redirect '/success'
  end
end

get '/success' do
  erb :index
end

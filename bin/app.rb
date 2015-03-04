require 'sinatra'
require 'pony'
require 'data_mapper'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

class Email

  include DataMapper::Resource

  property :email, String, :format => :email_address, :required => true

end

enable :sessions
use Rack::Session::Cookie, :expire_after => 2592000,
                           :secret => 'fc683cd9ed1990ca2ea10b84e5e6fba048c24929'

get '/' do
  erb :email_form
end

post '/' do

  session[:name] = params[:name]
  session[:email] = params[:email]
  session[:body] = params[:body]

  Pony.mail({
    :to => "info@misdepartment.com",
    :from => session[:email],
    :subject => "Inquiry from MIS Department website",
    :body => "From: " + session[:name] + "
    Message: " + session[:body],
    :via => :smtp
    })
  redirect '/success'
end

get '/success' do
  erb :index, :locals => {:name => session[:name], :email => session[:email], :body => session[:body]}
end

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

  # create a variable for each form field
  # name = "submitted[your_name]".to_sym
  # email = "submitted[your_e_mail_address]".to_sym
  # subject = "submitted[subject]".to_sym
  # reason = "submitted[reason_for_contact]".to_sym
  # message = "submitted[message]".to_sym

  reqparams = [:name, :email, :subject, :reason, :message]
  responses = []

  reqparams.each do |r|
    unless r.nil?
      responses.push([r,true])
    end
  end

  puts responses

  to = "info@misdepartment.com"
  name = params[:name]
  from = params[:email]
  subject = params[:subject]
  reason = params[:reason]
  mailbody = [
    :reason,
    :message
  ]

  # loop through all body variables and concatenate to string with \n in between
  # unless
  #   mailbody.each do |e|
  #     body << params[e]
  #   end
  # end

  # validate name, email and body

  # if validation passes

  Pony.mail({
    to: to,
    from: from,
    subject: subject,
    body: body
  })
end

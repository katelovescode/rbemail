require 'sinatra'
require 'pony'

# ruby configs
set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

# while true; do curl --data "submitted[your_name]=kate&submitted[your_e_mail_address]=kklemp@misdepartment.com&submitted[subject]=what" http://localhost:8080; sleep 5; done

post '/' do

  # loops through all "submitted" form fields based on Drupal weird form names as submitted["actual name"]
  form = params[:submitted]

  # empty responses array
  responses = []

  # array of ["actual name"] values of required fields (still based on Drupal that gives forms weird names)
  reqpar = [
    "your_name",
    "your_e_mail_address",
    "subject",
    "reason_for_contact",
    "message"
  ]

  # loops through all required parameters
  reqpar.each do |k|
    # checks for nil on each parameter value - if not nil, add "key name" with "true" value for responses array, puts values for testing
    unless form[k].nil?
      responses.push([k,true])
      puts k + " " + form[k]
    # if nil, add "key name" with "false" value for responses array
    else
      responses.push([k,false])
      puts k + " empty"
    end
  end

 # separate logic for required & non-required fields
 # kill it if required are missing
 # regex the email address
 # validate other fields
 # if all fields are OK, Pony.mail, if not, don't mail but send JSON
 # return file data as JSON - show success or specific failed fields


    # use the below as an example to concatenate string

    # loop through all body variables and concatenate to string with \n in between
    # unless
    #   mailbody.each do |e|
    #     body << params[e]
    #   end
    # end


    # use the below to send mail

    # Pony.mail({
    #   to: to,
    #   from: from,
    #   subject: subject,
    #   body: body
    # })

end

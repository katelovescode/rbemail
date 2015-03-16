require 'sinatra'
require 'pony'
require_relative "config.rb"

# ruby configs
set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

# this will die (9393 port - shotgun)
# while true; do curl --data "submitted[your_name]=kate&submitted[your_e_mail_address]=kklemp@misdepartment.com&submitted[subject]=what" http://localhost:9393; sleep 5; done

# this will pass (9393 port - shotgun)
# while true; do curl --data "submitted[your_name]=kate&submitted[your_e_mail_address]=kklemp@misdepartment.com&submitted[subject]=what&submitted[reason_for_contact]=becuz" http://localhost:9393; sleep 5; done

get '/' do
  # erb :email_form
  erb :drupal_form
end

post '/' do

  # global variables and empty arrays
  formstatus = true # used to test for validations and kill if not passed

  class Field # set up a class to process each form field
    def initialize(n,v,r,t)
      @name = n
      @value = v
      @required = r
      @title = t
    end

    def show
      puts "Name: " + @name
      puts "Value: " + @value
      puts "Required: " + @required
      puts "Title: " + @title
    end
  end

  unless $fieldarray.nil?
    $form = params[$fieldarray]
  else
    $form = params
  end

  $form.each do |k,v|

    r = "false"
    t = k.split('_').map(&:capitalize).join(' ')

    $required.each do |x|
      if k == x
        r = "true"
      end
    end

    $optional.each do |x|
      if k == x
        r = "false"
      end
    end

    if r == ""
      # kill it with fire
    end

    Field.new(k,v,r,t).show

  end

############ #KILLA

  # # loop through the fields array
  # fields.each do |f|
  #   # format: ["name",true/false,"value"] for each field; add the form input value to the 4th array element
  #   f[3] = form[f[0]]
  #   # kill it if required are missing
  #   if f[3] == nil && f[1] == true
  #     # kill it
  #     formstatus = false
  #   end
  # end
  #
  # ########################################
  # # VALIDATE SPECIFIC FIELDS HERE
  # ########################################
  #
  # # HTML name tags of your field here
  # email = "your_e_mail_address"
  #
  # testemail = fields.select { |a| a[0] == email }
  # testemail.each do |t|
  #   emltest = t[3]
  #   # uncomment below to test non-passable email
  #   # emltest = "this"
  #   if emltest[/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i] == nil
  #     formstatus = false
  #   end
  # end
  #
  # ########################################
  # # AFTER ALL VALIDATION, KILL OR PASS
  # ########################################
  #
  # # kill switch if anything passes a false formstatus
  # if formstatus == false
  #   # puts "kill it all"
  # end
  #
  # # pony mail if everything passes a true formstatus
  # if formstatus == true
  #   # puts "go for it"
  #
  #   ########################################
  #   # SET PONY FIELDS
  #   ########################################
  #
  #   ffield = fields.select { |a| a[2] == "from" }
  #   ffield.each do |f|
  #     from = f[3]
  #   end
  #   sfield = fields.select { |a| a[2] == "subject" }
  #   sfield.each do |s|
  #     subject = s[3]
  #   end
  #   bfields = fields.select { |a| a[2] == "body" }
  #   bfields.each do |b|
  #     body << b[0].to_s + ": " + b[3].to_s + "\n"
  #   end
  #
  #   # puts "From: " + from
  #   # puts "To: " + to
  #   # puts "Subject: " + subject
  #   # puts "Body: " + body
  #
  # end

 # # if all fields are OK, Pony.mail, if not, don't mail but send JSON
 # # return file data as JSON - show success or specific failed fields
 #
 #
 #    # use the below as an example to concatenate string
 #
 #    # loop through all body variables and concatenate to string with \n in between
 #    # unless
 #    #   mailbody.each do |e|
 #    #     body << params[e]
 #    #   end
 #    # end
 #
 #
 #    # use the below to send mail
 #
 #    # Pony.mail({
 #    #   to: to,
 #    #   from: from,
 #    #   subject: subject,
 #    #   body: body
 #    # })

 return true

end

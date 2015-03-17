require 'sinatra'
require 'pony'
require_relative "config.rb"

# ruby configs
set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

########################################
# TESTING COMMANDS
########################################

# this will die (9393 port - shotgun)
# while true; do curl --data "submitted[your_name]=kate&submitted[your_e_mail_address]=kklemp@misdepartment.com&submitted[subject]=what" http://localhost:9393; sleep 10; done

# this will pass (9393 port - shotgun)
# while true; do curl --data "submitted[your_name]=kate&submitted[your_e_mail_address]=kklemp@misdepartment.com&submitted[subject]=what&submitted[reason_for_contact]=becuz" http://localhost:9393; sleep 10; done

# form params with no drupal submitted array (9393 port - shotgun)
# while true; do curl --data "name=kate&email=kklemp@misdepartment.com&subject=what&reason=becuz" http://localhost:9393; sleep 10; done

########################################
# TESTING ERB TEMPLATES W/ FORMS
########################################

get '/' do
  # this is for testing non-drupal form names
  erb :email_form
  # erb :drupal_form
end

########################################
# FORM POST ACTION
########################################

# upon posting a form at the root page
post '/' do

  ########################################
  # GLOBALS
  ########################################

  # global variables and empty arrays
  formstatus = true # used to test for validations and kill if not passed
  form = []
  $allfields = []

  ########################################
  # FIELD CLASS
  ########################################

  class Field # set up a class to process each form field into an object
    def initialize(*args) #initialize the object with name, value, required and title elements
      @name, @value, @required, @title = args
    end

    def show # display all elements in the class object
      puts "Name: " + @name
      puts "Value: " + @value
      puts "Required: " + @required
      puts "Title: " + @title
    end

    def add # add all form values that are aggregated from the form input to an allfields array to be used for validation and submission
      $allfields.push([@name,@value,@required,@title])
    end
  end

  ########################################
  # CHECK CONFIG FOR DRUPAL FORM ARRAY SYNTAX
  ########################################

  # if $fieldarray is present (e.g. we are using drupal, which arrays its form fields)
  unless $fieldarray.nil?
    # the form variable is the result array of the parameters that are found in the fieldarray
    form = params[$fieldarray]
  else
    # loop through the form fields and add each form field key, value to the form array variable
    params.each do |key,value|
      form.push([key,value])
    end
  end

  ########################################
  # PROCESS FORM FIELDS THROUGH CONFIG (REQUIRED/OPTIONAL, TITLE)
  ########################################

  # loop through the form variable and add in required and title elements
  form.each do |k,v|

    # initialize required and found variables
    r, found = false

    # "Prettify" the title - take out any HTML tag spacing punctuation and change to spaces, capitalize to make it more readable
    t = k.split(/[[:punct:]]/).map(&:capitalize).join(' ')

    # if this form field is in the $required list in config, mark it as found, change the required value to true
    $required.each do |x|
      if k == x
        r, found = true
      end
    end

    # if this form field is in the $optional list in config, mark it as found, change the required value to false
    $optional.each do |x|
      if k == x
        found = true
        r = false
      end
    end

    # if this form field is in neither list, kill it with an error message
    if found == false
      # kill it with fire, alert the developer that they forgot to put their form fields in their configuration file
      puts "Form field '#{k}' is not listed in config.rb, please go back and add it to the configuration file."
      formstatus = false
    end

    Field.new(k,v,r,t).add

  end

  ########################################
  # VALIDATE FORM FIELDS
  ########################################

  # make sure required fields are actually filled out
  $allfields.each do |arr|

    # explode the array into named variables
    nme, val, req, ttl = arr[0], arr[1], arr[2], arr[3]

    # test to make sure required fields are filled out
    if req == true && val == ""
      formstatus = false
    end

    # use this for any email fields in the form
    $emailf.each do |x|
      if nme == x
        if val[/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i] == nil
          formstatus = false
        end
      end
    end

  end

  puts formstatus
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

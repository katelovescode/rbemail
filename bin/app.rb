require 'sinatra'
require 'pony'
require 'json'
require_relative "config.rb"

# ruby configs
set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

########################################
# TESTING CONSOLE COMMANDS
########################################

# this will die (9393 port - shotgun)
# while true; do curl --data "submitted[your_name]=kate&submitted[your_e_mail_address]=kklemp@misdepartment.com&submitted[subject]=what" http://localhost:9393; sleep 10; done

# this will pass (9393 port - shotgun)
# while true; do curl --data "submitted[your_name]=kate&submitted[your_e_mail_address]=kklemp@misdepartment.com&submitted[subject]=what&submitted[reason_for_contact]=becuz" http://localhost:9393; sleep 10; done

# form params with no drupal submitted array (9393 port - shotgun)
# while true; do curl --data "name=kate&email=kklemp@misdepartment.com&subject=what&reason=becuz" http://localhost:9393; sleep 10; done

########################################
# TESTING ERB TEMPLATES W/ FORMS - USING BROWSER
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
  to = ""
  from = ""
  subject = ""
  body = ""
  $symbols = []
  $entries = []
  $combine = []
  $allfields = []
  $hashfields = []
  $h = {}

  ########################################
  # FIELD CLASS
  ########################################

  class Field # set up a class to process each form field into an object
    def initialize(*args) #initialize the object with name, value, required and title elements
      @name, @value, @required, @title = args
    end

    def add # add all form values that are aggregated from the form input to an allfields array to be used for validation and submission
      $symbols = ["name", "value", "required", "title"] # for generating JSON objects
      $entries = [@name, @value, @required, @title] # for generating JSON objects and email fields
      $h = Hash[$symbols.zip($entries)] # turn each field's components into a hash
      $allfields.push($entries) # push all field entries to be processed and sent w/ Pony
      $hashfields.push($h) # push all field entries in an array of hashes to be output as JSON
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
  # PROCESS FORM FIELDS SUBMITTED (ADDS REQUIRED/OPTIONAL, TITLE)
  ########################################

  # loop through the form variable and add in required and title elements
  form.each do |k,v|

    # initialize required and found variables
    r, found = false, false

    # "Prettify" the title - take out any HTML tag spacing punctuation and change to spaces, capitalize to make it more readable
    t = k.split(/[[:punct:]]/).map(&:capitalize).join(' ')

    # if this form field is in the $required list in config, mark it as found, change the required value to true
    $required.each do |x|
      if k == x
        r, found = true, true
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
      # alert the developer that they forgot to put their form fields in their configuration file
      puts "Form field '#{k}' is not listed in config.rb, please go back and add it to the configuration file."
      formstatus = false
    end

    # create a field object and add it to the $allfields array using the method above
    Field.new(k,v,r,t).add

  end

  ########################################
  # LOOP THROUGH ALL PROCESSED FIELDS
  ########################################

  $allfields.each do |arr|

    # explode the array into named variables
    nme, val, req, ttl = arr[0], arr[1], arr[2], arr[3]

    ########################################
    # VALIDATIONS
    ########################################

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

    ########################################
    # ASSIGN PONY FIELDS
    ########################################

    # check $f_to variable in config; if it's not a list of email addresses, get the value like any other form field
    $f_to.each do |x|
      if x[/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i] == nil
        if nme == $f_to
          to = val
        end
      else
        to = $f_to.join(',')
      end
    end

    # if this is the same as the $f_from variable, get the value
    if nme == $f_from
      from = val
    end

    # if this is the same as the $f_subject variable, get the value
    if nme == $f_subject
      subject = val
    end

    # combine all body fields in the config file with line breaks
    $f_body.each do |x|
      if nme == x
        body << ttl + ": " + val + "\n"
      end
    end

  end

  ########################################
  # WRITE TO JSON
  ########################################

  $j = $hashfields.to_json

  # for testing the JSON output in the terminal, uncomment to see prettified JSON
  # $parsed = JSON.parse($j)
  # puts JSON.pretty_generate($parsed)

  File.open("data/temp.json","w") do |f|
    f.write($j)
  end

  ########################################
  # AFTER ALL VALIDATION, KILL OR PASS
  ########################################

  puts formstatus

  if formstatus == false
    # output JSON and AJAX call - still need Sunil's help on this
    puts "kill it all"
  end

  if formstatus == true
    Pony.mail({
      to: to,
      from: from,
      subject: subject,
      body: body
      })
  end

 return true

end

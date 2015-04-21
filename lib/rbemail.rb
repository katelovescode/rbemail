require 'sinatra'
require 'sinatra/cross_origin'
require 'pony'
require 'json'
require_relative "config.rb"

# ruby configs
set :port, 9393
set :root, File.expand_path("..", File.dirname(__FILE__))

########################################
# TESTING ERB TEMPLATES W/ FORMS - USING BROWSER
########################################

# get '/' do
#   # this is for testing non-drupal form names
#   # erb :email_form
#
#   erb :drupal_form
# end

########################################
# FORM POST ACTION
########################################

# upon posting a form at the root page
post '/' do
  cross_origin
  ########################################
  # GLOBALS
  ########################################

  # global variables and empty arrays
  form = []
  to = ""
  from = ""
  subject = ""
  body = ""
  $hashfields = []
  $tomails = []

  ########################################
  # FIELD FUNCTION
  ########################################

  def field(*args) # set up a class to process each form field into an object
    @fieldname, @value, @required, @title, @formpass = args
    $symbols = ["fieldname", "value", "required", "title", "formpass"] # for generating JSON objects
    $entries = [@fieldname, @value, @required, @title, @formpass] # for generating JSON objects and email fields
    $h = Hash[$symbols.zip($entries)] # turn each field's components into a hash
    $hashfields.push($h) # push all field entries in an array of hashes to be output as JSON
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
  # VALIDATE DEVELOPER CONFIGURATION
  ########################################

  # test for missing required fields or extra fields that shouldn't be submitted
  $combined = ($required + $optional + $botcatch)
  $testarray = form.keys

  # if a required field isn't submitted at all, kill it
  if not $required & $testarray == $required
    s = ("Required field(s) missing: " + ($required - $testarray).join(", ")).to_s
    $j = {error: s}.to_json
  elsif not ($testarray - $combined).empty?
    s = ("Extra field(s) submitted: " + ($testarray - $combined).join(", ")).to_s
    $j = {error: s}.to_json
  else
    ########################################
    # VALIDATE FORM SUBMISSION AND PUSH TO JSON & PONY
    ########################################

    # loop through the form variable and add in required and title elements
    form.each do |k,v|

      # set required variable
      r = $required.include? k

      # validate for empty required fields and bad emails
      f = 0
      if r == true && v == ""
        f = 1 # error code for missing required field
      end

      # validate all email fields as requested by configuration file
      if $emailf.include? k
        # email regex
        if (not v == "") && v[/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i] == nil
          f = 2 # error code for bad email format
        end
      end

      # "Prettify" the title - take out any HTML tag spacing punctuation and change to spaces, capitalize to make it more readable
      t = k.split(/[[:punct:]]/).map(&:capitalize).join(' ')

      # assign the Pony "from" value
      if $f_from == k
        from = v
      else
        from = ENV['F_FROM']
      end

      # if Pony to value is assigned by form entry, assign the Pony "to" value
      if $f_to.include? k
        to = v
      else
        to = ""
      end

      # assign the Pony "subject" value
      if $f_subject.to_s == k
        subject = v
      end

      # concatenate all body fields to the single Pony "body" value with line breaks and titles
      if $f_body.include? k
        body << t + ": " + v + "\n"
      end

      # create a field object and add it to the $hashfields array using the method above
      field k,v,r,t,f

    end

    # if the Pony "to" value is still unassigned (not a form field), assign Pony "to" field to string of email addresses in config file
    if to == ""
      $f_to.each do |x|
        if not x[/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i] == nil
          $tomails.push(x)
        end
      end
      to = $tomails.join(",")
    end

    ########################################
    # WRITE TO JSON
    ########################################

    $j = $hashfields.to_json


    ########################################
    # AFTER ALL VALIDATION, KILL OR PASS
    ########################################

    sendemail = true

    $hashfields.each do |x|
      if x.values[4] != 0
        sendemail = false
      end
    end

    if sendemail
      Pony.mail({to: to,from: from,subject: subject,body: body,via: $send_via,via_options: { address: $smtp_address,port: $smtp_port,user_name: $smtp_user,password: $smtp_pass,authentication: $smtp_auth,domain: $smtp_domain}})
    end

  end

  content_type :json
  return $j

end

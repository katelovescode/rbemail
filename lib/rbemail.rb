require 'sinatra'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'pony'
require 'json'
require_relative "config.rb"

class Rbemail < Sinatra::Base
  register Sinatra::CrossOrigin
  include Config
  extend Config

  self.load_config

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
  
  get '/' do
    "hello world"
  end

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
    to_array = []
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
    if $settings.fieldarray!=nil
      # the form variable is the result array of the parameters that are found in the fieldarray
      form = params[$settings.fieldarray]
    else
      # loop through the form fields and add each form field key, value to the form array variable
      form = params
    end
  
    ########################################
    # VALIDATE DEVELOPER CONFIGURATION
    ########################################
  
    # test for missing required fields or extra fields that shouldn't be submitted
    $combined = ($settings.required + $settings.optional + $settings.botcatch)
    $testarray = form.keys
  
    # if a required field isn't submitted at all, kill it
    if not $settings.required & $testarray == $settings.required
      s = ("Required field(s) missing: " + (@settiungs.required - $testarray).join(", ")).to_s
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
        r = $settings.required.include? k
  
        # validate for empty required fields and bad emails
        f = 0
        if r == true && v == ""
          f = 1 # error code for missing required field
        end
  
        # validate all email fields as requested by configuration file
        if $settings.emailf.include? k
          # email regex
          if (not v == "") && v[/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i] == nil
            f = 2 # error code for bad email format
          end
        end
  
        # "Prettify" the title - take out any HTML tag spacing punctuation and change to spaces, capitalize to make it more readable
        t = k.split(/[[:punct:]]/).map(&:capitalize).join(' ')
  
        # assign the Pony "from" value
        if $settings.f_from == k
          from = v
        end
  
        # if Pony to value is assigned by form entry, assign the Pony "to" value
        if $settings.f_to.include? k
          to = v
        end
  
        # assign the Pony "subject" value
        if $settings.f_subject.to_s == k
          subject = v
        end
  
        # concatenate all body fields to the single Pony "body" value with line breaks and titles
        if $settings.f_body.include? k
          body << t + ": " + v + "\n"
        end
  
        # create a field object and add it to the $hashfields array using the method above
        field k,v,r,t,f
  
      end
  
      # if "from" value is an email address in the config, set "from"
      if $settings.f_from[/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i] != nil
        from = $settings.f_from
      end
  
      # if the Pony "to" value is still unassigned (not a form field), assign Pony "to" field to string of email addresses in config file
      if to == ""
        $settings.f_to.each do |x|
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
        Pony.mail({to: to,from: from,subject: subject,body: body,via: $settings.send_via,via_options: { address: $settings.smtp_address,port: $settings.smtp_port,user_name: $settings.smtp_user,password: $settings.smtp_pass,authentication: $settings.smtp_auth,domain: $settings.smtp_domain}})
      end
  
    end
  
    content_type :json
    return $j
  
  end

end

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

  # upon posting a form at the root page
  post '/' do
    cross_origin

    # global variables and empty arrays
    form = []
    to = ""
    from = ""
    subject = ""
    body = ""
    to_array = []
    $hashfields = []
    $tomails = []
    emailformat = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

    # field method
    def field(*args)
      @fieldname, @value, @required, @title, @formpass = args
      $symbols = ["fieldname", "value", "required", "title", "formpass"] # for generating JSON objects
      $entries = [@fieldname, @value, @required, @title, @formpass] # for generating JSON objects and email fields
      $h = Hash[$symbols.zip($entries)] # turn each field's components into a hash
      $hashfields.push($h) # push all field entries in an array of hashes to be output as JSON
    end

    # if $fieldarray is present (e.g. we are using drupal, which arrays its form fields)
    $settings.fieldarray!=nil ? form = params[$settings.fieldarray] : form = params

    # test for missing required fields or extra fields that shouldn't be submitted
    $combined = ($settings.required + $settings.optional + $settings.botcatch)
    $testarray = form.keys

    # if a required field isn't submitted at all, kill it
    if not $settings.required & $testarray == $settings.required
      s = ("Required field(s) missing: " + ($settings.required - $testarray).join(", ")).to_s
      $j = {error: s}.to_json
    elsif not ($testarray - $combined).empty?
      s = ("Extra field(s) submitted: " + ($testarray - $combined).join(", ")).to_s
      $j = {error: s}.to_json
    else

      # prep to send
      # loop through the form variable and add in required and title elements
      form.each do |k,v|

        # r variable - true if this is in the required list
        r = $settings.required.include? k

        # f variable - error codes
        f = 0
        f = 1 if (r == true and v == "") # empty required field
        if $settings.emailf.include? k
          f = 2 if v != "" and not v =~ emailformat
        end
        f = 3 if $settings.botcatch.join == k #caught a bot

        # t variable - "Prettify" the title of the form field
        t = k.split(/[[:punct:]]/).map(&:capitalize).join(' ')

        # assign the Pony values, if they are form fields (body concatenates all body fields with line breaks)
        from = v if $settings.f_from == k
        to = v if $settings.f_to.include? k
        subject = v if $settings.f_subject.to_s == k
        body << t + ": " + v + "\n" if $settings.f_body.include? k

        # create a field object and add it to the $hashfields array using the method above
        field k,v,r,t,f

      end

      # if "from" value is an email address in the config, set "from"
      from = $settings.f_from if $settings.f_from =~ emailformat

      # if "subject" value is hardcoded in the config, set "subject"
      subject = $settings.f_subject.to_s if subject == ""

      # if the Pony "to" value is still unassigned (not a form field), assign Pony "to" field to string of email addresses in config file
      if to == ""
        $settings.f_to.each { |x| $tomails.push(x) if x =~ emailformat }
        to = $tomails.join(",")
      end

      # write to json
      $j = $hashfields.to_json

      # after all validation, kill or pass
      $sendemail = true

      $hashfields.each { |x| $sendemail = false if x.values[4] != 0 }

      Pony.mail({
        to: to,
        from: from,
        subject: subject,
        body: body,
        via: $settings.send_via,
        via_options: {
          address: $settings.smtp_address,
          port: $settings.smtp_port,
          user_name: $settings.smtp_user,
          password: $settings.smtp_pass,
          authentication: $settings.smtp_auth,
          domain: $settings.smtp_domain
        }
      }) if $sendemail

    end

    content_type :json
    return $j

  end

end

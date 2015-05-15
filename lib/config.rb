require 'dotenv'
require 'ostruct'

module Config

  def load_config
    if defined?(ENV['RACK_ENV'])
      dotenvfile1 = ".env.#{ENV['RACK_ENV']}"
      Dotenv.load dotenvfile1
    end

    settings = {}

    settings[:required] = ENV['REQUIRED'].chomp('"').reverse.chomp('"').reverse.split(" ")
    settings[:optional] = ENV['OPTIONAL'].chomp('"').reverse.chomp('"').reverse.split(" ")
    settings[:emailf] = ENV['EMAILF'].chomp('"').reverse.chomp('"').reverse.split(" ")
    settings[:botcatch] = ENV['BOTCATCH'].chomp('"').reverse.chomp('"').reverse.split(" ")

    settings[:f_to] = ENV['F_TO'].chomp('"').reverse.chomp('"').reverse.split(" ")
    settings[:f_from] = ENV['F_FROM'].chomp('"').reverse.chomp('"').reverse
    settings[:f_subject] = ENV['F_SUBJECT'].chomp('"').reverse.chomp('"').reverse
    settings[:f_body] = ENV['F_BODY'].chomp('"').reverse.chomp('"').reverse.split(" ")

    unless ENV['FIELDARRAY'] == ""
      settings[:fieldarray] = ENV['FIELDARRAY'].chomp('"').reverse.chomp('"').reverse.to_sym
    end

    settings[:send_via] = ENV['SEND_VIA'].chomp('"').reverse.chomp('"').reverse.to_sym
    settings[:smtp_address] = ENV['SMTP_ADDRESS'].chomp('"').reverse.chomp('"').reverse
    settings[:smtp_port] = ENV['SMTP_PORT'].chomp('"').reverse.chomp('"').reverse
    if ENV['SMTP_AUTH'] == "\"\""
      settings[:smtp_auth] = nil
      settings[:smtp_user] = nil
      settings[:smtp_pass] = nil
    else
      settings[:smtp_auth] = ENV['SMTP_AUTH'].chomp('"').reverse.chomp('"').reverse.to_sym
      settings[:smtp_user] = ENV['SMTP_USER'].chomp('"').reverse.chomp('"').reverse
      settings[:smtp_pass] = ENV['SMTP_PASS'].chomp('"').reverse.chomp('"').reverse
    end
    settings[:smtp_domain] = ENV['SMTP_DOMAIN'].chomp('"').reverse.chomp('"').reverse

    $settings = OpenStruct.new settings
    
  end

  def change_config(key, value)
    $settings[key] = value
  end
end

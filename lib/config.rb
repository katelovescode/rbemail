require 'dotenv'
require 'ostruct'

module Config

  def load_config
    if defined?(ENV['RACK_ENV'])
      dotenvfile1 = ".env.#{ENV['RACK_ENV']}"
      Dotenv.load dotenvfile1
    end

    settings = {}
    settings[:required] = ENV['REQUIRED'].split(" ")
    settings[:optional] = ENV['OPTIONAL'].split(" ")
    settings[:emailf] = ENV['EMAILF'].split(" ")
    settings[:botcatch] = ENV['BOTCATCH'].split(" ")

    settings[:f_to] = ENV['F_TO'].split(" ")
    settings[:f_from] = ENV['F_FROM']
    settings[:f_subject] = ENV['F_SUBJECT']
    settings[:f_body] = ENV['F_BODY'].split(" ")

    unless ENV['FIELDARRAY'] == ""
      settings[:fieldarray] = ENV['FIELDARRAY'].to_sym
    end

    settings[:send_via] = ENV['SEND_VIA'].to_sym
    settings[:smtp_address] = ENV['SMTP_ADDRESS']
    settings[:smtp_port] = ENV['SMTP_PORT']
    if ENV['SMTP_AUTH'] == "\"\""
      settings[:smtp_auth] = nil
      settings[:smtp_user] = nil
      settings[:smtp_pass] = nil
    else
      settings[:smtp_auth] = ENV['SMTP_AUTH'].to_sym
      settings[:smtp_user] = ENV['SMTP_USER']
      settings[:smtp_pass] = ENV['SMTP_PASS']
    end
    settings[:smtp_domain] = ENV['SMTP_DOMAIN']

    $settings = OpenStruct.new settings

  end

  def change_config(key, value)
    $settings[key] = value
  end
end

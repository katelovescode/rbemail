require './bin/app.rb'
require 'test/unit'
require 'rack/test'

class EmailTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_my_default
    get '/'
    assert_equal 'Hello World', last_response.body
  end

  def test_hello_form
    get '/hello/'
    assert last_response.ok?
    assert last_response.body.include?('A Greeting')
  end

  def test_hello_form_post
    post '/hello/', params={:name => 'Frank', :greeting => 'Hi'}
    assert last_response.ok?
    assert last_response.body.include?("I just wanted to say")
  end
end


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

# get '/' do
#   # this is for testing non-drupal form names
#   erb :email_form
#
#   # erb :drupal_form
# end

# for testing the JSON output in the terminal, uncomment to see prettified JSON
# $parsed = JSON.parse($j)
# puts JSON.pretty_generate($parsed)

# test JSON output into a file - uncomment below
# File.open("data/temp.json","w") do |f|
#   f.write($j)
# end

ENV['RACK_ENV'] = 'test'

# submitted[your_name]=test&submitted[your_e_mail_address]=test@test.com&submitted[subject]=what&submitted[reason_for_contact]=becuz

require 'rbemail'  # <-- your sinatra app
require 'rspec'
require 'rack/test'
require 'net/http'
require 'uri'
require 'json'
require File.expand_path('../spec_helper', __FILE__)


describe "Rbemail" do
  include Rack::Test::Methods
  let(:good_request) {
    {
      example_fieldarray: {
        example_name: "test",
        example_email: "email@example.com",
        example_message: "hello world",
        example_phone: "123-456-7890",
        example_rating: "4"
      }
    }
  }

  # set up mailcatcher for the tests
  before do
    `mailcatcher`
  end

  # tear it down!
  after do
    `kill $(ps -ef | grep mailcatcher | grep ruby | awk '{ print $2 }')`
  end

  def app
    Sinatra::Application
  end

  it "accepts POST requests at root" do
    post "/", good_request
    expect(last_response.status).to equal(200)
  end

end


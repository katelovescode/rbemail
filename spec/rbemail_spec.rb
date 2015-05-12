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

  context "field array is present, such as in drupal" do
    let(:example_email) { "email@example.com" }
    let(:good_request) {
      {
        example_fieldarray: {
          example_name: "test",
          example_email: example_email,
          example_message: "hello world",
          example_phone: "123-456-7890",
          example_rating: "4"
        }
      }
    }
    let(:mailcatcher_endpoint) { "http://127.0.0.1:1080" }

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

    it "produces a real email" do
      post "/", good_request
      uri = URI.parse("#{mailcatcher_endpoint}/messages")
      response = Net::HTTP.get_response(uri)
      messages = JSON.parse(response.body)
      last_message = messages[0]
      expect(last_message['sender']).to eq("<#{example_email}>")
    end

  end

  context "field array is not present, such as in a hand-coded form" do

    let(:example_email) { "email@example.com" }
    let(:good_request) {
      {
        example_name: "test",
        example_email: example_email,
        example_message: "hello world",
        example_phone: "123-456-7890",
        example_rating: "4"
      }
    }
    let(:mailcatcher_endpoint) { "http://127.0.0.1:1080" }

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

    it "produces a real email" do
      post "/", good_request
      uri = URI.parse("#{mailcatcher_endpoint}/messages")
      response = Net::HTTP.get_response(uri)
      messages = JSON.parse(response.body)
      last_message = messages[0]
      expect(last_message['sender']).to eq("<#{example_email}>")
    end

  end

end

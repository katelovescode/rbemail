ENV['RACK_ENV'] = 'test'

# submitted[your_name]=test&submitted[your_e_mail_address]=test@test.com&submitted[subject]=what&submitted[reason_for_contact]=becuz

require 'net/http'
require 'uri'
require 'json'
require File.expand_path('../spec_helper', __FILE__)

describe Rbemail do

  let(:example_from_email) { "email@example.com" }
  let(:mailcatcher_endpoint) { "http://127.0.0.1:1080" }
  let(:uri) { URI.parse("#{mailcatcher_endpoint}/messages") }
  let(:response) { Net::HTTP.get_response(uri) }
  let(:messages) { JSON.parse(response.body) }
  let(:last_message) { messages[0] }

  let(:good_request) {
    {
      example_name: "test",
      example_from_email: example_from_email,
      example_message: "hello world",
      example_phone: "123-456-7890",
      example_rating: "4"
    }
  }
  let(:missing_required) {
    {
      example_from_email: example_from_email,
      example_message: "hello world",
      example_phone: "123-456-7890",
      example_rating: "4"
    }
  }
  let(:extra_field) {
    {
      example_name: "test",
      example_from_email: example_from_email,
      example_message: "hello world",
      example_phone: "123-456-7890",
      example_rating: "4",
      example_testing: "this doesn't belong"
    }
  }
  let(:empty_required) {
    {
      example_name: "",
      example_from_email: example_from_email,
      example_message: "hello world",
      example_phone: "123-456-7890",
      example_rating: "4"
    }
  }
  let(:bad_email) {
    {
      example_name: "test",
      example_from_email: "email@whatev",
      example_message: "hello world",
      example_phone: "123-456-7890",
      example_rating: "4"
    }
  }
  let(:bot_field) {
    {
      example_name: "test",
      example_from_email: example_from_email,
      example_message: "hello world",
      example_phone: "123-456-7890",
      example_rating: "4",
      example_botfield: "thisisabot"
    }
  }
  let(:to_form_field) {
    {
      example_name: "test",
      example_from_email: example_from_email,
      example_message: "hello world",
      example_phone: "123-456-7890",
      example_to_email: "to@test.com",
      example_rating: "4"
    }
  }

  context "field array is not present (e.g. hand-coded form)" do
    # set up mailcatcher for the tests
    before do
      Rbemail::change_config('fieldarray',nil)
      `mailcatcher`
    end

    # tear it down!
    after do
      `kill $(ps -ef | grep mailcatcher | grep ruby | awk '{ print $2 }')`
    end

    it "accepts POST requests at root" do
      post "/", good_request
      expect(last_response.status).to eq(200)
    end

    it "produces a real email on a good request" do
      post "/", good_request
      expect(last_message['sender']).to eq("<#{example_from_email}>")
    end

    it "rejects a request that is missing a required field" do
      post "/", missing_required
      $json = JSON.parse $j
      expect($json["error"]).to start_with "Required field(s) missing:"
      expect(last_message).to be nil
    end

    it "rejects a request with an additional field" do
      post "/", extra_field
      $json = JSON.parse $j
      expect($json["error"]).to start_with "Extra field(s) submitted:"
      expect(last_message).to be nil
    end

    it "rejects a request if a required field is empty" do
      post "/", empty_required
      expect($sendemail).to be false
      expect(last_message).to be nil
    end

    it "rejects a request if an email field doesn't validate" do
      post "/", bad_email
      expect($sendemail).to be false
      expect(last_message).to be nil
    end

    it "rejects a request if the botfield is filled out" do
      post "/", bot_field
      expect($sendemail).to be false
      expect(last_message).to be nil
    end

    it "accepts a request with the 'to' value assigned from a form field" do
      fix = (ENV['REQUIRED'] + " example_to_email").split(" ")
      Rbemail::change_config('f_to','example_to_email')
      Rbemail::change_config('required',fix)

      post "/", to_form_field
      $hashfields.each do |x|
        if x["fieldname"] == "example_to_email"
          expect(x["value"]).to eq("#{to_form_field[:example_to_email]}")
        end
      end
      expect(last_message['sender']).to eq("<#{example_from_email}>")

      tofixback = ENV['F_TO'].split(" ")
      reqfixback = ENV['REQUIRED'].split(" ")
      Rbemail::change_config('f_to',tofixback)
      Rbemail::change_config('required',reqfixback)
    end

    it "accepts a request with multiple 'to' addresses" do
      fix = ("email@example1.com email@example2.com").split(" ")
      Rbemail::change_config('f_to',fix)

      post "/", good_request
      expect(last_message['sender']).to eq("<#{example_from_email}>")

      tofixback = ENV['F_TO'].split(" ")
      Rbemail::change_config('f_to',tofixback)
    end

  end

  context "field array is present (e.g. drupal)" do
    let(:fieldarray_good_request) {
      { example_fieldarray: good_request }
    }
    let(:fieldarray_missing_required) {
      { example_fieldarray: missing_required }
    }
    let(:fieldarray_extra_field) {
      { example_fieldarray: extra_field }
    }
    let(:fieldarray_empty_required) {
      { example_fieldarray: empty_required }
    }
    let(:fieldarray_bad_email) {
      { example_fieldarray: bad_email }
    }
    let(:fieldarray_bot_field) {
      { example_fieldarray: bot_field }
    }
    let(:fieldarray_to_form_field) {
      { example_fieldarray: to_form_field }
    }

    # set up mailcatcher for the tests
    before do
      Rbemail::change_config('fieldarray','example_fieldarray')
      `mailcatcher`
    end

    # tear it down!
    after do
      `kill $(ps -ef | grep mailcatcher | grep ruby | awk '{ print $2 }')`
    end

    it "accepts POST requests at root" do
      post "/", fieldarray_good_request
      expect(last_response.status).to eq(200)
    end

    it "produces a real email" do
      post "/", fieldarray_good_request
      expect(last_message['sender']).to eq("<#{example_from_email}>")
    end

    it "rejects a request that is missing a required field" do
      post "/", fieldarray_missing_required
      $json = JSON.parse $j
      expect($json["error"]).to start_with "Required field(s) missing:"
      expect(last_message).to be nil
    end

    it "rejects a request with an additional field" do
      post "/", fieldarray_extra_field
      $json = JSON.parse $j
      expect($json["error"]).to start_with "Extra field(s) submitted:"
      expect(last_message).to be nil
    end

    it "rejects a request if a required field is empty" do
      post "/", fieldarray_empty_required
      expect($sendemail).to be false
      expect(last_message).to be nil
    end

    it "rejects a request if an email field doesn't validate" do
      post "/", fieldarray_bad_email
      expect($sendemail).to be false
      expect(last_message).to be nil
    end

    it "rejects a request if the botfield is filled out" do
      post "/", fieldarray_bot_field
      expect($sendemail).to be false
      expect(last_message).to be nil
    end

    it "accepts a request with the 'to' value assigned from a form field" do
      fix = (ENV['REQUIRED'] + " example_to_email").split(" ")
      Rbemail::change_config('f_to','example_to_email')
      Rbemail::change_config('required',fix)

      post "/", fieldarray_to_form_field
      $hashfields.each do |x|
        if x["fieldname"] == "example_to_email"
          expect(x["value"]).to eq("#{fieldarray_to_form_field[:example_fieldarray][:example_to_email]}")
        end
      end
      expect(last_message['sender']).to eq("<#{example_from_email}>")

      tofixback = ENV['F_TO'].split(" ")
      reqfixback = ENV['REQUIRED'].split(" ")
      Rbemail::change_config('f_to',tofixback)
      Rbemail::change_config('required',reqfixback)
    end

    it "accepts a request with multiple 'to' addresses" do
      fix = ("email@example1.com email@example2.com").split(" ")
      Rbemail::change_config('f_to',fix)

      post "/", fieldarray_good_request
      expect(last_message['sender']).to eq("<#{example_from_email}>")

      tofixback = ENV['F_TO'].split(" ")
      Rbemail::change_config('f_to',tofixback)
    end

  end


end

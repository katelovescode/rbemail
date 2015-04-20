require 'rubygems'
require 'sinatra'

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

require_relative 'lib/rbemail.rb'

run Sinatra::Application

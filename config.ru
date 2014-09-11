require 'rubygems'
require 'bundler'

# require 'sinatra/base'
# require 'securerandom'
# require 'mechanize'
# require 'httparty'
# require 'nokogiri'
# require 'open-uri'
# require 'redis'
# require 'json'
# require 'uri'
# require 'rss'
# # require 'pry'
Bundler.require(:default, ENV["RACK_ENV"].to_sym)


require './app'
run App

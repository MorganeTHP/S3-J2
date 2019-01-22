require 'bundler'

Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper.rb'

Scrapper.all
Scrapper.new.save_as_json
Scrapper.save_as_spreadsheet
Scrapper.save_as_csv

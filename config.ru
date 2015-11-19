require 'rubygems'
require File.join(File.dirname(__FILE__), 'app.rb')

use Rack::Static,
  :urls => ["/public"]

run SecretSanta

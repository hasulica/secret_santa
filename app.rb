require 'sinatra/base'
require 'json'
require 'rest-client'

class SecretSanta < Sinatra::Base
  get '/' do
    'Hello SecretSanta!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end

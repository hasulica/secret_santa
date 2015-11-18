require 'sinatra/base'
require 'json'
require 'rest-client'

CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

class SecretSanta < Sinatra::Base
  get '/' do
    erb :index, locals: { client_id: CLIENT_ID }
  end

  get '/callback' do
    session_code = request.env['rack.request.query_hash']['code']

    result = RestClient.post('https://github.com/login/oauth/access_token',
                             { client_id: CLIENT_ID,
                               client_secret: CLIENT_SECRET,
                               code: session_code },
                             accept: :json)

    access_token = JSON.parse(result)['access_token']
    scopes = JSON.parse(result)['scope'].split(',')
    has_user_email_scope = scopes.include? 'user:email'
    auth_result =
      JSON.parse(RestClient.get('https://api.github.com/user',
                                            params: {access_token: access_token }))
    if has_user_email_scope
      auth_result['private_emails'] =
        JSON.parse(RestClient.get('https://api.github.com/user/emails',
                                  params: { access_token: access_token }))
    end

    erb :basic, locals: auth_result
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME
end

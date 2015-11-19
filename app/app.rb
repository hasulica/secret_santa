ENV['RACK_ENV'] ||= 'development'

require 'sinatra/base'
require 'rest_client'
require 'json'
require_relative 'october_cohort'
require_relative 'data_mapper_setup'

CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

class SecretSanta < Sinatra::Base
  use Rack::Session::Pool, cookie_only: false

  def authenticated?
    session[:access_token]
  end

  def authenticate!
    erb :index, locals: { client_id: CLIENT_ID }
  end

  get '/' do
    if !authenticated?
      authenticate!
    else
      access_token = session[:access_token]
      scopes = []

      begin
        auth_result = RestClient.get('https://api.github.com/user',
                                     params: { access_token: access_token },
                                     accept: :json)
      rescue => e
        session[:access_token] = nil
        return authenticate!
      end

      if auth_result.headers.include? :x_oauth_scopes
        scopes = auth_result.headers[:x_oauth_scopes].split(', ')
      end

      auth_result = JSON.parse(auth_result)

      if OCTOBER_COHORT.include? auth_result['login']
        erb :home, locals: { user: current_user(auth_result) }
      else
        body "Sorry, you're not in our cohort. Kthxbye!"
      end
    end
  end

  get '/callback' do
    session_code = request.env['rack.request.query_hash']['code']

    result = RestClient.post('https://github.com/login/oauth/access_token',
                             { client_id: CLIENT_ID,
                               client_secret: CLIENT_SECRET,
                               code: session_code },
                             accept: :json)

    session[:access_token] = JSON.parse(result)['access_token']

    redirect '/'
  end

  helpers do
    def current_user(auth_result)
      @users = User.all
      if @users.any? { |user| user.login == auth_result['login'] }
        @user = @users.first(auth_result['login'])
      else
        @user = User.create(login: auth_result['login'],
                            name: auth_result['name'],
                            email: auth_result['email'])
      end
      return @user
    end
  end

end

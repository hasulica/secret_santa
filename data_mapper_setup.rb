require 'data_mapper'
require 'dm-postgres-adapter'

require_relative 'model/user'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/secret_santa_#{ENV['RACK_ENV']}")
DataMapper.finalize

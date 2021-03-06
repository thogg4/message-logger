require 'sinatra'
require 'sass'
require 'coffee_script'
require 'time'
require 'json'
require './lib/auto_link.rb'

# set up db
require 'mongoid'
Dir.glob('./models/*.rb').each {|file| require_relative file }
configure do
  Mongoid.configure do |config|
    if ENV['MONGOHQ_URL']
      conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
      uri = URI.parse(ENV['MONGOHQ_URL'])
      config.master = conn.db(uri.path.gsub(/^\//, ''))
    else
      config.master = Mongo::Connection.from_uri(ENV['MESSAGE_LOG_DB_URL']).db(ENV['MESSAGE_LOG_DB_NAME'])
    end
  end
end


get '/' do
  today = Time.now.utc.strftime('%Y-%m-%d').to_s
  redirect to("/#{today}")
end

get '/:date' do |date|
  @date = date
  @messages = get_messages_by_date(date)
  erb :date
end

get '/import/ant' do
  @messages = get_important_messages
  erb :important
end

get '/get/json/messages' do
  content_type :json
  Message.all.to_a.to_json
end

# any asset routes
get '/stylesheets/:name.css' do |n|
  scss :"stylesheets/#{n}", :views => 'public'
end
get '/javascripts/app.js' do
  coffee :app, :views => 'public/javascripts'
end

def get_messages_by_date(date)
  Message.all.select { |m| m.date.strftime('%Y-%m-%d') == date }
end

def all_dates
  Message.all.map { |m| m.date.strftime('%Y-%m-%d') }.uniq!
end

def get_important_messages
  Message.all.select { |m| m.important == true }
end

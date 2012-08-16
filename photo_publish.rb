require 'sinatra'
require 'sass'
require 'coffee_script'

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
      config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('photo_publish')
    end
  end
end


require './lib/dropbox_sdk.rb'

APP_KEY = "wj4to93enq5zu6j"
APP_SECRET = "rv4ggn1fkkq4q20"
ACCESS_TYPE = :app_folder

enable :sessions

get '/' do
  erb :index
end

get '/:username' do
  if session[:client]

    client = session[:client]
    @photos = []
    client.metadata('/')['contents'].each do |piece|
      @photos << client.media(piece['path'])
    end
    erb :username

  else
    redirect to('/')
  end

end

get '/log/in' do
  if !params[:oauth_token]
    session_object = DropboxSession.new(APP_KEY, APP_SECRET)
    session[:session] = session_object.serialize
    redirect to(session_object.get_authorize_url(request.url))
  else
    session_object = DropboxSession.deserialize(session[:session])
    token = session_object.get_access_token
    session[:session] = session_object.serialize
    session[:client] = DropboxClient.new(session_object)

    username = username_from_email(session[:client].account_info['email'])
    if !User.where(username: username).exists?
      User.create(
        username: username,
        key: token.key,
        secret: token.secret,
        hash: 'thiswillbeahash'
      )
    end
    redirect to('/')
  end
end

get '/log/out' do
  session[:session] = nil if session[:session]
  session[:client] = nil if session[:client]
  redirect to('/')
end

# any asset routes
get '/stylesheets/:name.css' do |n|
  scss :"stylesheets/#{n}", :views => 'public'
end
get '/javascripts/app.js' do
  coffee :app, :views => 'public/javascripts'
end


def username_from_email(email)
  email.match(/(.*)@/)[1]
end



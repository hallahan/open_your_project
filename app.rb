require 'sinatra'
require 'haml'
require 'sass'

get '/' do
  haml :home
end

get '/style.css' do
  content_type 'text/css'
  sass :style
end


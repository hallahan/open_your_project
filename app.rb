require 'sinatra'
require 'haml'

get '/' do
  haml :home
end

get '/viz/tags.json' do
  content_type 'application/json'
  %~
    {
      "children": [
        {
          "name": "Spirituality",
          "size": "12"
        },
        {
          "name": "Collaboration",
          "size": "57"
        },
        {
          "name": "Technology",
          "size": "27"
        },
        {
          "name": "Education",
          "size": "44"
        },
        {
          "name": "Culture",
          "size": "29"
        },
        {
          "name": "Arts",
          "size": "35"
        },
        {
          "name": "Social",
          "size": "22"
        }
      ]
    }
  ~
end

get '/viz/curators.json' do
  content_type 'application/json'
  %~
    {
      "children": [
        {
          "name": "Ward",
          "size": "431"
        },
        {
          "name": "Bryan",
          "size": "19"
        },
        {
          "name": "Harlan",
          "size": "27"
        },
        {
          "name": "Nick",
          "size": "106"
        },
        {
          "name": "Stephen",
          "size": "29"
        },
        {
          "name": "Sven",
          "size": "35"
        },
        {
          "name": "Adam",
          "size": "22"
        }
      ]
    }
  ~
end

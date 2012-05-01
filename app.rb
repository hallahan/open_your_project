require 'sinatra'
require 'haml'

get '/' do
  haml :home
end

get '/viz/tags.json' do
  content_type 'application/json'
  %~
    {
      "name": "farm",
      "children": [
        {
          "name": "bar.noah.lvh.me",
          "children": [
            {
              "name": "Welcome Visitors",
              "size": "1"
            }
          ]
        },
        {
          "name": "foo.noah.lvh.me",
          "children": [
            {
              "name": "Welcome Visitors",
              "size": "1"
            }
          ]
        },
        {
          "name": "localhost",
          "children": [
            {
              "name": "Air Temperature",
              "size": "1"
            },
            {
              "name": "D3 Bars",
              "size": "1"
            },
            {
              "name": "D3 Bars",
              "size": "1"
            },
            {
              "name": "D3 Line",
              "size": "1"
            },
            {
              "name": "Welcome Visitors",
              "size": "1"
            }
          ]
        },
        {
          "name": "lvh.me",
          "children": [
            {
              "name": "D3 Line",
              "size": "1"
            },
            {
              "name": "Welcome Visitors",
              "size": "1"
            }
          ]
        },
        {
          "name": "noah.lvh.me",
          "children": [
            {
              "name": "Welcome Visitors",
              "size": "1"
            }
          ]
        }
      ]
    }
  ~
end
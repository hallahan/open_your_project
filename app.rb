require 'haml'
require 'html_massage'
require 'json'
require 'nokogiri'
require 'rest_client'
require 'sinatra'

Dir[File.expand_path("lib/**/*.rb", File.dirname(__FILE__))].each { |lib| require lib }

def development?
  ENV['RACK_ENV'] == 'development'
end

get '/' do
  haml :home
end

post '/' do
  url = params[:url] =~ %r{^https?://} ? params[:url] : "http://#{params[:url]}"
  html = RestClient.get url
  title = (Nokogiri::HTML(html) / :title).inner_text

  sfw_page_data = {
    'title' => title,
    'story' => []
  }

  text = HtmlMassage.text html
  chunks = text.split(/\n{2,}/)
  chunks.each do |chunk|
    sfw_page_data['story'] << ({
      'type' => 'paragraph',
      'id' => RandomId.generate,
      'text' => chunk
    })
  end

  create_action = {
    'type' => 'create',
    'id' => RandomId.generate,
    'item' => sfw_page_data
  }
  create_action_json = JSON.pretty_generate(create_action)

  topic = url.gsub(%r{^https?://(www\.)?}, '').split('.').first
  subdomain = "#{topic}.#{params[:username].parameterize}"
  slug = title.parameterize
  action_path = "/page/#{slug}/action"
  port_suffix = development? ? ':1111' : ''
  sfw_host = "#{request.scheme}://#{subdomain}.#{request.host}#{port_suffix}"

  begin
    RestClient.put "#{sfw_host}#{action_path}", :action => create_action_json, :content_type => :json, :accept => :json
  rescue RestClient::Conflict
    raise 'deal with conflicts'
  end

  redirect "#{sfw_host}/view/#{slug}"
end

get '/curators' do
  haml :curators
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

get '/viz/curators-full.json' do
  content_type 'application/json'
  %~
    {
      "name":"Open Your Project",
      "size":"139",
      "data":{
        "$dim":77,
        "$color":"hsl(200,99%,55%)",
        "json_path":"/network.json"
      },"children":[
      {
        "name":"Tristan Kromer",
        "size":"139",
        "data":{
          "$dim":77,
          "$color":"hsl(200,99%,88%)",
          "json_path":"/users/tristan-kromer/network.json"
        },
        "children":[
          {
            "name":"Tech BA SV",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/tristan-kromer/projects/tech-ba-sv/network.json"
            }
          },
          {
            "name":"Chicken curry",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/tristan-kromer4/projects/chicken-curry/network.json"
            }
          },
          {
            "name":"Leading by Design",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/harlan-wood/projects/leading-by-design/network.json"
            }
          }
        ]
      },
      {
        "name":"Harlan T Wood",
        "size":"139",
        "data":{
          "$dim":77,
          "$color":"hsl(200,99%,88%)",
          "json_path":"/users/harlan-knight-wood/network.json"
        },
        "children":[
          {
            "name":"Free Info",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/harlan-knight-wood/projects/free-info/network.json"
            }
          },
          {
            "name":"Enlightened Structure",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/harlan-knight-wood/projects/enlightened-structure/network.json"
            }
          },
          {
            "name":"Heart of the Sun",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/harlan-knight-wood/projects/heart-of-the-sun/network.json"
            }
          },
          {
            "name":"open film genesis",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/harlan-knight-wood/projects/open-film-genesis/network.json"
            }
          },
          {
            "name":"Superfood Desserts",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/harlan-knight-wood/projects/superfood-desserts/network.json"
            }
          }
        ]
      },
      {
        "name":"Chris Farmer",
        "size":"139",
        "data":{
          "$dim":77,
          "$color":"hsl(200,99%,88%)",
          "json_path":"/users/chris-farmer/network.json"
        },
        "children":[
          {
            "name":"Open Source Cosmology",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/chris-farmer/projects/open-source-cosmology/network.json"
            }
          },
          {
            "name":"The Sorcerer's Apprentice",
            "size":"99",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/chris-farmer/projects/open-source-cosmology/network.json"
            }
          }
        ]
      },
      {
        "name":"Bill Ayers",
        "size":"139",
        "data":{
          "$dim":77,
          "$color":"hsl(200,99%,88%)",
          "json_path":"/users/bill-ayers/network.json"
        },
        "children":[
          {
            "name":"Ted's Head",
            "size":"139",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/bill-ayers/projects/ted-s-head/network.json"
            }
          },
          {
            "name":"Ted's Head 2",
            "size":"77",
            "data":{
              "$dim":7,
              "$color":"hsl(50,99%,77%)",
              "json_path":"/users/bill-ayers/projects/ted-s-head/network.json"
            }
          }
        ]
      }
    ]}
  ~
end

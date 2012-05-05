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
  if request.host.match /^www\./
    haml :home
  else
    port_suffix = request.port == 80 ? '' : ":#{request.port}"
    redirect "#{request.scheme}://www.#{request.host}#{port_suffix}"
  end
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

  topic = params[:topic].parameterize if params[:topic]
  topic ||= url.gsub(%r{^https?://(www\.)?}, '').split('.').first
  subdomain = "#{topic}.#{params[:username].parameterize}"
  slug = title.parameterize
  sfw_host = "#{request.scheme}://#{subdomain}.#{base_host}"
  action_path = "/page/#{slug}/action"

  begin
    RestClient.put "#{sfw_host}#{action_path}", :action => create_action_json, :content_type => :json, :accept => :json
  rescue RestClient::Conflict
    raise 'TODO: deal with conflicts'
  end

  redirect "#{sfw_host}/view/#{slug}"
end

get %r{^/curators$} do
  @viz = :curators
  @json_path = "http://sfw.#{base_host}/viz/#{@viz}.json"
  haml @viz
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

def base_host
  request.host.gsub(/^www\./, '') << ( development? ? ':1111' : '' )
end

require 'haml'
require 'html_massage'
require 'json'
require 'nokogiri'
require 'rest_client'
require 'sinatra'

Dir[File.expand_path("lib/**/*.rb", File.dirname(__FILE__))].each { |lib| require lib }

enable :logging, :dump_errors, :raise_errors
set :show_exceptions, true if development?

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

get %r{^/viz/(\w+)$} do |viz|
  @viz = viz
  @json_path = "http://sfw.#{base_host}/viz/#{viz}.json"
  haml viz.to_sym
end

#get '/curators' do
#  @viz = :curators
#  @json_path = "http://sfw.#{base_host}/viz/#{@viz}.json"
#  haml @viz
#
#  # Code formerly in SFW around splitting out curators and collections:
#  #
#  #
#  #set :minimum_subdomain_length, 8   # This is our application logic
#  #set :maximum_subdomain_length, 63  # This is a hard limit set by internet standards
#  #set :subdomain_pattern, "[a-z0-9][a-z0-9-]{#{settings.minimum_subdomain_length-1},#{settings.maximum_subdomain_length-1}}"
#  #set :curator_subdomain_pattern,             "(#{settings.subdomain_pattern})"
#  #set :curator_collection_subdomain_pattern,  "(#{settings.subdomain_pattern})\\.(#{settings.subdomain_pattern})"
#  #
#  #
#  #curators_hashes = []
#  #curators = {"name" => "", "children" => curators_hashes}
#  #
#  #for each page obj:
#  #  next unless page['site'] && page['site'].match(/^#{settings.curator_collection_subdomain_pattern}\./)
#  #
#  #  collection_subdomain, curator_subdomain = $1, $2
#  #
#  #  curator_hash = curators_hashes.find{ |curator_hash| curator_hash['name'] == curator_subdomain }
#  #  unless curator_hash
#  #    curator_hash = {"name" => curator_subdomain, "children" => []}
#  #    curators_hashes << curator_hash
#  #  end
#
#end

def base_host
  request.host.gsub(/^www\./, '') << ( development? ? ':1111' : '' )
end

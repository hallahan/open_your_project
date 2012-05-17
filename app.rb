require 'active_support/core_ext'
require 'haml'
require 'json'
require 'nokogiri'
require 'rest_client'
require 'sinatra'

Dir[File.expand_path("lib/**/*.rb", File.dirname(__FILE__))].each { |lib| require lib }

include FedWiki

enable :logging, :dump_errors, :raise_errors
set :show_exceptions, true if development?

raise "Please set the environment variable 'SFW_BASE_DOMAIN'" if ENV['SFW_BASE_DOMAIN'].nil? || ENV['SFW_BASE_DOMAIN'].empty?

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
  doc = Nokogiri::HTML(html)
  options = params.symbolize_keys.slice(:username, :topic)
  fork_url = fedwiki_fork doc, url, options
  redirect fork_url
end

get %r{^/viz/(\w+)$} do |viz|
  @viz = viz
  @json_path = "http://sfw.#{ENV['SFW_BASE_DOMAIN']}/viz/#{viz}.json"
  haml viz.to_sym
end

#get '/curators' do
#  @viz = :curators
#  @json_path = "http://sfw.#{ENV['SFW_BASE_DOMAIN']}/viz/#{@viz}.json"
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


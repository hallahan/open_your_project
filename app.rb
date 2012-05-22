require 'active_support'
require 'action_view'
require 'action_view/context'
require 'action_view/template/handlers/erb'
require 'action_view/helpers'
require 'action_view/helpers/form_helper'
require 'formtastic'
require 'haml'
require 'json'
require 'nokogiri'
require 'rest_client'
require 'sinatra'

#require 'sinatra_more/markup_plugin'

Dir[File.expand_path("lib/**/*.rb", File.dirname(__FILE__))].each { |lib| require lib }
require (File.expand_path 'fork', File.dirname(__FILE__))

ActiveSupport.on_load(:action_view) do
  include Formtastic::Helpers::FormHelper
end

class Controller < Sinatra::Base

helpers ActionController::RecordIdentifier
helpers ActionView::Context
helpers ActionView::Helpers::FormHelper
helpers Formtastic::Helpers::FormHelper

#register SinatraMore::MarkupPlugin

enable :logging, :dump_errors, :raise_errors
set :show_exceptions, true if development?

raise "Please set the environment variable 'SFW_BASE_DOMAIN'" if ENV['SFW_BASE_DOMAIN'].nil? || ENV['SFW_BASE_DOMAIN'].empty?

def form_pre_filled?
  development?
  false
end

def development?
  ENV['RACK_ENV'] == 'development'
end

get '/' do
  if request.host.match /^www\./
    @fork = Fork.new
    haml :home
  else
    port_suffix = request.port == 80 ? '' : ":#{request.port}"
    redirect "#{request.scheme}://www.#{request.host}#{port_suffix}"
  end
end

def forks_path;
  '/'
end

post '/' do
  @fork = Fork.new(params)
  p 222, @fork.valid?
  (haml :home && return) if !@fork.valid?

  html = RestClient.get @fork.url
  doc = Nokogiri::HTML(html)
  begin
    fork_url = FedWiki.open(doc, @fork.url, :username => @fork.username, :topic => @fork.topic)
    redirect fork_url
  rescue InterWiki::NoKnownOpenLicense
    # add error to @fork
    haml :home
  end
end

def protect_against_forgery?
  false
end

get %r{^/viz/(\w+)$} do |viz|
  @viz = viz
  @json_path = "http://sfw.#{ENV['SFW_BASE_DOMAIN']}/viz/#{viz}.json"
  haml viz.to_sym
end

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


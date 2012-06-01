require 'fedwiki/fork'

class PagesController < ApplicationController
  def new
    if request.host.match /^#{ENV['APP_SUBDOMAIN']}\./
      page_attrs = {
        :url => 'http://en.wikipedia.org/wiki/Technological_singularity',
        :username => 'John Q. Public',
        :topic => 'Singularity',
      } if CONFIG.form_pre_filled
      @page = Page.new(page_attrs || {})
    else
      #port_suffix = request.port == 80 ? '' : ":#{request.port}"
      #redirect "#{request.scheme}://#{APP_SUBDOMAIN}.#{request.host}#{port_suffix}"
      redirect_to "http://enlightenedstructure.org/Software_Zero/"
    end
  end

  def create
    @page = Page.new(params[:page])
    (render :new and return) unless @page.valid?

    html = RestClient.get @page.url
    doc = Nokogiri::HTML(html)
    begin
      page_url = FedWiki.open(doc, @page.url, :username => @page.username, :topic => @page.topic)
      redirect_to page_url
    rescue FedWiki::NoKnownOpenLicense
      # add error to @fork
      render :new
    end
  end

  def index
    @viz = :collections
    @json_path = "http://sfw.#{ENV['SFW_BASE_DOMAIN']}/viz/#{@viz}.json"
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


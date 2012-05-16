require 'pismo'
require 'html_massage'
require 'rest_client'

module FedWiki

  SUBDOMAIN_PATTERN = "[a-z0-9][a-z0-9-]{0,62}" # subdomains max at 63 characters

  def fedwiki_fork(doc, url, options={})

    html = doc.to_s

    metadata = Pismo::Document.new(html) # rescue nil
                                         # for a list of metadata properties, see https://github.com/peterc/pismo
                                         # To limit keywords to specific items we care about, consider this doc fragment --
                                         #   New! The keywords method accepts optional arguments. These are the current defaults:
                                         #   :stem_at => 20, :word_length_limit => 15, :limit => 20, :remove_stopwords => true, :minimum_score => 2
                                         #   You can also pass an array to keywords with :hints => arr if you want only words of your choosing to be found.

    return if html.empty? || !metadata || url =~ /%23/ # whats up with %23?

    h1 = (doc / :h1).first
    title = h1 ? h1.inner_text : metadata.title
    keywords = metadata.keywords.map(&:first)

    sfw_page_data = {
      'title' => title,
      'keywords' => keywords,
      'story' => [],
    }

    # Two ways to check the last updated time, both unsatisfactory...
    # sfw_page_data.merge! 'updated_at' => page.headers['Last-Modified']
    # sfw_page_data.merge! 'updated_at' => meta.datetime.utc.iso8601 if meta.datetime rescue nil

    #ap sfw_page_data

    begin
      html = HtmlMassage.html html, :source_url => url, :links => :absolute
    rescue Encoding::CompatibilityError
      return # TODO: manage this inside the html_massage gem!
    end

    #p 444, url
    url_chunks = url.match(%r{
      ^
      https?://
      (?:www\.)?
      (#{SUBDOMAIN_PATTERN})
      ((?:\.#{SUBDOMAIN_PATTERN})+)?
      (?::\d+)?  # port
      (/.*)      # path
      $
    }x).to_a
    url_chunks.shift # discard full regexp match
    #p 333, url_chunks
    path = url_chunks.pop
    slug = path.match(%r{^/?$}) ? 'home' : path.gsub(%r[^/\d{4}/\d{2}/\d{2}], '').parameterize
    origin_domain = url_chunks.join

    doc = Nokogiri::HTML.fragment(html)
    links = doc / 'a'
    links.each do |link|
      if match = link['href'].to_s.match(%r[.+?#{origin_domain}(?::\d+)?(?<href_path>/.*)$])
        link_slug = match['href_path'].parameterize
        link['href'] = "/#{link_slug}.html"
        link['data-page-name'] = link_slug
        link['class'] = (link['class'] && !link['class'].empty?) ? "#{link['class']} internal" : 'internal'
        link['title'] = "origin"
      end
    end
    html = doc.to_html

    #html.rstrip_lines!
    chunks = html.split(/\n{2,}/)
    chunks.each do |chunk|
      sfw_page_data['story'] << ({
        'type' => 'paragraph',
        'id' => RandomId.generate,
        'text' => chunk
      })
    end

    if options[:username]
      username = options[:username].parameterize
      topic = options[:topic].empty? ? url_chunks.first : options[:topic].parameterize
      subdomain = "#{topic}.#{username}"
    else
      subdomain = "#{origin_domain}.on"
    end

    sfw_site = "#{subdomain}.#{ENV['SFW_BASE_DOMAIN']}"
    sfw_action_url = "http://#{sfw_site}/page/#{slug}/action"

    begin
      sfw_do(sfw_action_url, :create, sfw_page_data)
    rescue RestClient::Conflict
      sfw_do(sfw_action_url, :update, sfw_page_data)
    end

    fork_url = "http://#{sfw_site}/view/#{slug}"
  end

  def sfw_do(sfw_action_url, action, sfw_page_data)
    action_json = JSON.pretty_generate 'type' => action, 'item' => sfw_page_data
    RestClient.put "#{sfw_action_url}", :action => action_json, :content_type => :json, :accept => :json
  end

end


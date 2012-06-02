require 'pismo'
require 'html_massage'
require 'rest_client'

require_relative 'random_id'
require_relative '../../config/initializers/string'

module FedWiki

  class NoKnownOpenLicense < RuntimeError ; end

  SUBDOMAIN_PATTERN = "[a-zA-Z0-9][a-zA-Z0-9-]{0,62}" # subdomains max at 63 characters.  although technically lower case, URLs may come in in mixed case.

  OPEN_LICENSE_PATTERNS = %w[
    gnu.org/licenses
    creativecommons.org/licenses
  ]

  SFW_BASE_DOMAIN = ENV['SFW_BASE_DOMAIN'] || raise("please set the environment variable SFW_BASE_DOMAIN")

  class << self
    def open(doc, url, options={})
      puts
      print "    ... Trying #{url} ... "

      return if doc.nil?

      license_links = open_license_links(doc)
      raise NoKnownOpenLicense if license_links.empty?

      html = doc.to_s

      metadata = Pismo::Document.new(html) rescue nil  # pismo occasionally crashes, eg on invalid UTF8
                                           # for a list of metadata properties, see https://github.com/peterc/pismo
                                           # To limit keywords to specific items we care about, consider this doc fragment --
                                           #   New! The keywords method accepts optional arguments. These are the current defaults:
                                           #   :stem_at => 20, :word_length_limit => 15, :limit => 20, :remove_stopwords => true, :minimum_score => 2
                                           #   You can also pass an array to keywords with :hints => arr if you want only words of your choosing to be found.

      return if html.empty? || !metadata || url =~ /%23/ # whats up with %23?

      title = extract_title(doc) || metadata.title
      keywords = metadata.keywords.map(&:first)

      sfw_page_data = {
        'title' => title,
        'keywords' => keywords,
        'license_links' => license_links,
        'story' => [],
      }

      # Two ways to check the last updated time, both unsatisfactory...
      # sfw_page_data.merge! 'updated_at' => page.headers['Last-Modified']
      # sfw_page_data.merge! 'updated_at' => meta.datetime.utc.iso8601 if meta.datetime rescue nil

      #ap sfw_page_data

      html = massage_html(html, url)

      url_chunks = url.match(%r{
        ^
        https?://
        (?:www\.)?
        (#{SUBDOMAIN_PATTERN})
        ((?:\.#{SUBDOMAIN_PATTERN})+)?
      }x).to_a

      url_chunks.shift # discard full regexp match
      origin_domain = url_chunks.join
      slug = url.slug

      if options[:username]
        username = options[:username].parameterize
        topic = options[:topic].empty? ? url_chunks.first : options[:topic].parameterize
        subdomain = "#{topic}.#{username}"
      else
        subdomain = "#{origin_domain}.on"
      end

      sfw_site = "#{subdomain}.#{ENV['SFW_BASE_DOMAIN']}"
      sfw_action_url = "http://#{sfw_site}/page/#{slug}/action"

      doc = Nokogiri::HTML.fragment(html)
      links = doc / 'a'
      links.each do |link|
        if match = link['href'].to_s.match(%r[.+?#{origin_domain}(?::\d+)?(?<href_path>/.*)$])
          link_slug = match['href_path'].slug
          link['href'] = link_slug
          link['class'] = "#{link['class']} fedwiki-internal".strip # the class is for later client-side processing
        end
      end
      html = doc.to_html

      html.strip_lines!
      html_chunks = html.split(/\n{2,}/)
      sep = [%{<hr />}]
      attribution_html = [%{This page was forked with permission from <a href="#{url}" target="_blank">#{url}</a>}]

      (html_chunks + sep + attribution_html + sep + license_links).each do |html_chunk|
        sfw_page_data['story'] << ({
          'type' => 'paragraph',
          'id' => RandomId.generate,
          'text' => html_chunk
        })
      end

      begin
        sfw_do(sfw_action_url, :create, sfw_page_data)
      rescue RestClient::Conflict
        sfw_do(sfw_action_url, :update, sfw_page_data)
      end

      fork_url = "http://#{sfw_site}/view/#{slug}"
    end

    def massage_html(html, url)
      sanitize_options = HtmlMassage::DEFAULT_SANITIZE_OPTIONS.merge(
          :elements => %w[
            a img
            h1 h2 h3 hr
            table th tr td
            em strong b i
          ],
          :attributes => {
            :all => [],
            :a => %w[ href ],
            :img => %w[ src alt ],
          }
      )
      begin
        HtmlMassage.html html, :source_url => url, :links => :absolute, :images => :absolute, :sanitize => sanitize_options
      rescue Encoding::CompatibilityError
        return # TODO: manage this inside the html_massage gem!
      end
    end

    def open_license_links(doc)
      links = license_links(doc, 'a[rel="license"]')
      #!links.empty? ? links : license_links(doc, 'a')
    end

    def license_links(doc, selector)
      links = doc.css(selector).map do |license_link|
        OPEN_LICENSE_PATTERNS.map do |pattern|
          license_link.to_s if license_link['href'].to_s.match(Regexp.new pattern)
        end
      end
      links.flatten.compact
    end

    def extract_title(doc)
      %w[ div.title div.h0 h1 title ].each do |selector|
        if ( title_elements = doc.search( selector ) ).length == 1
          title = title_elements.first.content.split( /\s+(-|\|)/ ).first.to_s.strip
          return title unless title.empty?
        end
      end
      nil
    end

    def sfw_do(sfw_action_url, action, sfw_page_data)
      action_json = JSON.pretty_generate 'type' => action, 'item' => sfw_page_data
      #begin
      RestClient.put "#{sfw_action_url}", :action => action_json, :content_type => :json, :accept => :json
      #rescue RestClient::ResourceNotFound
      #  puts "!!! ERROR: SFW SERVER NOT FOUND at #{sfw_action_url}"
      #end
    end

  end
end


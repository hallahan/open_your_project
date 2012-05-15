module ForkDiffMerge

  def fork_content(doc, url)
    html = doc.to_s

    metadata = Pismo::Document.new(html) # rescue nil
    # for a list of metadata properties, see https://github.com/peterc/pismo
    # To limit keywords to specific items we care about, consider this doc fragment --
    #   New! The keywords method accepts optional arguments. These are the current defaults:
    #   :stem_at => 20, :word_length_limit => 15, :limit => 20, :remove_stopwords => true, :minimum_score => 2
    #   You can also pass an array to keywords with :hints => arr if you want only words of your choosing to be found.

    return if html.empty? || !metadata || url =~ /%23/  # whats up with %23?

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
      text = HtmlMassage.text html
      chunks = text.split(/\n{2,}/)
      chunks.each do |chunk|
        sfw_page_data['story'] << ({
          'type' => 'paragraph',
          'id' => RandomId.generate,
          'text' => chunk
        })
      end
    rescue Encoding::CompatibilityError
      return   # TODO: manage this inside the html_massage gem!
    end

    url_chunks = url.match(%r{
      ^
      https?://
      (?: www\.)?
      (#{SUBDOMAIN_PATTERN})
      ((?:\.#{SUBDOMAIN_PATTERN})+)
      (?::\d+)?
      (/.*)
      $
    }x).to_a

    url_chunks.shift # discard full regexp match
    path = url_chunks.pop
    origin_domain = url_chunks.join

    slug = path.gsub(%r[^/\d{4}/\d{2}/\d{2}], '').parameterize
    slug = 'home' if slug.empty?
    sfw_action_url = "http://#{origin_domain}.on.#{ENV['SFW_BASE_DOMAIN']}/page/#{slug}/action"

    begin
      sfw_do(sfw_action_url, :create, sfw_page_data)
    rescue RestClient::Conflict
      sfw_do(sfw_action_url, :merge, sfw_page_data)
    end

    puts "Created fedwiki page -->"
    puts "http://#{origin_domain}.on.#{ENV['SFW_BASE_DOMAIN']}/view/#{slug}"
  end

end
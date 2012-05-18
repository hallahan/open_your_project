class String
  def strip_lines!
    lines = split( $/ )    # $/ is the current ruby line ending, \n by default
    lines.map!( &:strip )
    processed = lines.join( $/ )
    processed.strip!
    replace( processed )
  end

  def slug(sep = '-')
    massaged = self.dup

    massaged.gsub!(/#.*$/, '')               # strip off anchor tags, eg #section-2
    massaged.gsub!(/\?.*$/, '')              # strip off query sting, eg ?cid=6a0
    massaged.gsub!(/\.[a-z]{3,10}$/i, '')     # strip off file extensions, eg .html

    match = massaged.match %r[
      ^
        (
          /\d{4}/\d{2}    # optional leading date stamp, eg 2012/12
          (?:/\d{2})?     #                              or 2012/12/21
        )?
        (.*?[a-z].*?)     # require at least one alpha char for slug, if we are stripping the date
      $
    ]xi
    massaged = match[2] if (match && match[1] && match[2])   # strip leading date

    massaged = 'home' if massaged.match(%r{^/?$})

    # Below is a simplified version of the code found in rails 3.2.1:
    # activesupport/lib/active_support/inflector/transliterate.rb
    # Note that the transliteration to ASCII has been removed for simplicity

    massaged.downcase!
    massaged.gsub!(/[^a-z0-9\-]+/, sep)  # differs from rails version: don't allow underscores
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      # No more than one of the separator in a row.
      massaged.gsub!(/#{re_sep}{2,}/, sep)
      # Remove leading/trailing separator.
      massaged.gsub!(/^#{re_sep}|#{re_sep}$/, '')
    end

    # print "\n    [ slug -> #{self} -> \n              #{massaged} ]"
    massaged
  end

end

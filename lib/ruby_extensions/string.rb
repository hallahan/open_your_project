class String
  def rstrip_lines!
    lines = split( $/ )    # $/ is the current ruby line ending, \n by default
    lines.map!( &:rstrip )
    processed = lines.join( $/ )
    processed.rstrip!
    replace( processed )
  end

  # Simplified version of the code found in rails 3.2.1:
  # activesupport/lib/active_support/inflector/transliterate.rb
  # Note that the transliteration to ASCII has been removed for simplicity
  def parameterize(sep='-')
    parameterized_string = self.downcase
    parameterized_string.gsub!(/[^a-z0-9\-]+/, sep)  # differs from rails version: don't allow underscores
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      # No more than one of the separator in a row.
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      # Remove leading/trailing separator.
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
    end
    parameterized_string
  end

end

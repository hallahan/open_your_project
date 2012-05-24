require File.expand_path("../../../lib/ruby_extensions/string", File.dirname(__FILE__))

describe String do
  describe '#slug' do
    %w[
      /2020/20                   2020-20
      /2020/20/                  2020-20
      /2020/20/22                2020-20-22
      /2020/20/22/1              2020-20-22-1
      /2020/20/22/a              a
      /2020/20/22/foo/bar        foo-bar
      /2020/20/foo/bar           foo-bar
      /wiki/Superintelligence    wiki-superintelligence
    ].
    each_slice(2) do |path, expected_slug|
      it "should convert the path #{path.inspect} to the slug #{expected_slug.inspect}" do
        path.slug.should == expected_slug
      end
    end

    [
      "Pride & Prejudice",             "pride-prejudice",
      "holy cats !!! you don't say",   "holy-cats-you-don-t-say",
      "---holy cats !!! ---------",    "holy-cats",
    ].
    each_slice(2) do |title, expected_slug|
      it "should convert the title #{title.inspect} to the slug #{expected_slug.inspect}" do
        title.slug.should == expected_slug
      end
    end

    # 'WORKING'
    section 'case and hyphen insensitive'
    test 'Welcome Visitors', 'welcome-visitors'
    test 'welcome visitors', 'welcome-visitors'
    test 'Welcome-visitors', 'welcome-visitors'


    section 'numbers and punctuation'
    test '2012 Report', '2012-report'
    test 'Ward\'s Wiki', 'wards-wiki'

    # 'PROBLEMATIC'
    section 'white space insenstive'
    test 'Welcome  Visitors', 'welcome-visitors'
    test '  Welcome Visitors', 'welcome-visitors'
    test 'Welcome Visitors  ', 'welcome-visitors'

    section 'foreign language'
    test 'Les Misérables', 'les-misérables'
    test 'Les Misérables', 'les-miserables'

  end
end


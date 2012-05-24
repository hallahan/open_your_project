# encoding: UTF-8
require File.expand_path("../../../lib/ruby_extensions/string", File.dirname(__FILE__))

def section (comment)
  puts "\n\t#{comment}\n"
end

def test (given, expected)
  actual = given.slug
  puts actual == expected ? "OK\t#{given}" : "YIKES\t#{given} => #{actual}, not #{expected} as expected"
end

# the following test cases presume to be implementation language agnostic
# perhaps they should be included from a common file

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
test 'Les Misérables', 'les-misérables'

#test '/2020/20', '2020-20'
#test '/2020/20/', '2020-20'
#test '/2020/20/22', '2020-20-22'
#test '/2020/20/22/1', '2020-20-22-1'
#test '/2020/20/22/a', 'a'
#test '/2020/20/22/foo/bar', 'foo-bar'
#test '/2020/20/foo/bar', 'foo-bar'
#test '/wiki/Superintelligence', 'wiki-superintelligence'


#describe String do
#  describe '#slug' do
#    %w[
#      /2020/20                   2020-20
#      /2020/20/                  2020-20
#      /2020/20/22                2020-20-22
#      /2020/20/22/1              2020-20-22-1
#      /2020/20/22/a              a
#      /2020/20/22/foo/bar        foo-bar
#      /2020/20/foo/bar           foo-bar
#      /wiki/Superintelligence    wiki-superintelligence
#    ].
#    each_slice(2) do |old, expected|
#      puts "test '#{old}', '#{expected}'"
#    end
#
#
#    [
#      "Pride & Prejudice",             "pride-prejudice",
#      "holy cats !!! you don't say",   "holy-cats-you-don-t-say",
#      "---holy cats !!! ---------",    "holy-cats",
#    ].
#    each_slice(2) do |title, expected_slug|
#      it "should convert the title #{title.inspect} to the slug #{expected_slug.inspect}" do
#        title.slug.should == expected_slug
#      end
#    end
#
#    # 'WORKING'
#    section 'case and hyphen insensitive'
#    test 'Welcome Visitors', 'welcome-visitors'
#    test 'welcome visitors', 'welcome-visitors'
#    test 'Welcome-visitors', 'welcome-visitors'
#
#
#    section 'numbers and punctuation'
#    test '2012 Report', '2012-report'
#    test 'Ward\'s Wiki', 'wards-wiki'
#
#    # 'PROBLEMATIC'
#    section 'white space insenstive'
#    test 'Welcome  Visitors', 'welcome-visitors'
#    test '  Welcome Visitors', 'welcome-visitors'
#    test 'Welcome Visitors  ', 'welcome-visitors'
#
#    section 'foreign language'
#    test 'Les Misérables', 'les-misérables'
#    test 'Les Misérables', 'les-miserables'
#
#  end
#end
#

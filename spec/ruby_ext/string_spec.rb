# encoding: UTF-8
require_relative "../../config/initializers/string"

def section (comment)
  $section = comment
  $counter = 0
end

def test (given, expected)
  describe "#{$section}: Test ##{$counter+=1}" do
    it "should convert the string #{given.inspect} to the slug #{expected.inspect}" do
      given.slug.should == expected
    end
  end
end

# the following test cases presume to be implementation language agnostic
# perhaps they should be included from a common file

section 'case and hyphen insensitive'
test 'Welcome Visitors', 'welcome-visitors'
test 'welcome visitors', 'welcome-visitors'
test 'Welcome-visitors', 'welcome-visitors'

section 'numbers and punctuation'
test '2012 Report', '2012-report'
test 'Ward\'s Wiki', 'wards-wiki'
test 'ø\'malley', 'ømalley'
test 'holy cats !!! you don\'t say', 'holy-cats-you-dont-say'
test 'Pride & Prejudice', 'pride-prejudice'
test '---holy cats !!! ---------', 'holy-cats'

section 'white space insenstive'
test 'Welcome  Visitors', 'welcome-visitors'
test '  Welcome Visitors', 'welcome-visitors'
test 'Welcome Visitors  ', 'welcome-visitors'

section 'foreign language'
test 'Les Misérables', 'les-misérables'
test 'Les Misérables', 'les-misérables'

section 'URLs'
test 'http://myblog.com/2020/20', '2020-20'
test 'http://myblog.com/2020/20/', '2020-20'
test 'http://myblog.com/2020/20/22', '2020-20-22'
test 'http://myblog.com/2020/20/22/-/-/---', '2020-20-22'
test 'http://myblog.com/2020/20/22/1', '2020-20-22-1'
test 'http://myblog.com/2020/20/22/a', 'a'
test 'http://myblog.com/2020/20/22/ø', 'ø'
test 'http://myblog.com/2020/20/22/foo/bar', 'foo-bar'
test 'http://myblog.com/2020/20/foo/bar', 'foo-bar'
test 'http://myblog.com/wiki/Superintelligence', 'wiki-superintelligence'
test 'http://myblog.com/wiki/Superintelligence.html', 'wiki-superintelligence'
test 'http://myblog.com/wiki/Superintelligence.mp3', 'wiki-superintelligence'
test 'http://myblog.com/wiki/Superintelligence.døm', 'wiki-superintelligence'
test 'http://myblog.com/', 'home'
test 'http://myblog.com', 'home'
test 'http://myblog.com:8181/', 'home'
test 'http://myblog.com:8181', 'home'

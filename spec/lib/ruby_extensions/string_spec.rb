require File.expand_path("../../../lib/ruby_extensions/string", File.dirname(__FILE__))

describe String do
  describe '#slug' do
    it 'should convert a path to a slug' do
      '/wiki/Superintelligence'.slug.should == 'wiki-superintelligence'
    end
  end
end

#"/2020/20"
#"/2020/20/"
#"/2020/20/22"
#"/2020/20/22/1"
#"/2020/20/22/foo/bar"
#"/2020/20/foo/bar"
#"2020-20"
#"2020-20-22"
#"2020-20-22-1"
#"2020-20-22-foo-bar"
#"2020-20-foo-bar"
#"holy fuck !!! you are good"
#"holy fuck !!! you are good---------"
#"holy-fuck-you-are-good"

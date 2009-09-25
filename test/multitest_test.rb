require File.join(File.dirname(__FILE__), 'test_helper')
require 'multitest'

class MultitestTest < Test::Unit::TestCase
  context "a Multitest" do
    setup do
      FileUtils.mkdir_p(File.join(File.dirname(__FILE__), '..', 'tmp'))
      FileUtils.rm_rf(File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'test.log')))
      @mt = Multitest.new([
        File.expand_path(File.join(File.dirname(__FILE__), 'tests', 'sample_test.rb')),
        File.expand_path(File.join(File.dirname(__FILE__), 'tests', 'another_test.rb'))
      ])
    end
    
    should "run three instances" do
      @mt.run
      assert File.exists?(File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'test.log')))
      File.open(File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'test.log'))) do |f|
        assert_equal %w(1 1 3).sort, f.read.split("\n").sort
      end
    end
  end
end

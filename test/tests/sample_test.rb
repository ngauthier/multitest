require File.join(File.dirname(__FILE__), '..', 'test_helper')

class SampleTest < Test::Unit::TestCase
  should "output some text to a file" do
    File.open(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'test.log')), 'a') do |f|
      f.write "1\n"
    end
  end
end

class SampleTestEnhanced < SampleTest
  # will inherite the test above
end

class SampleTestHelper
  def help
    # do something
  end
end

require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AnotherTest < Test::Unit::TestCase
  should "output some text to a file" do
    File.open(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'test.log')), 'a') do |f|
      f.write "3\n"
    end
  end
end

require File.join(File.dirname(__FILE__), 'test_helper')
class ConsumerTest < Test::Unit::TestCase
  def test_basic_setup
    consumer = OAuthConsumer.new('key', 'secret')
    assert_equal 'key', consumer.key
    assert_equal 'secret', consumer.secret
  end
  
  def test_setup_with_options
    consumer = OAuthConsumer.new('key', 'secret', :site => 'http://localhost:3001/', :scheme => :header)
    assert_equal 'http://localhost:3001/', consumer.site
    assert_equal :header, consumer.scheme
  end
end
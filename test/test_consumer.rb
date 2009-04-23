require File.join(File.dirname(__FILE__), 'test_helper')
class ConsumerTest < Test::Unit::TestCase
  def setup
    OAuthRequest.stubs(:generate_nonce).returns("nonce")
    OAuthRequest.stubs(:generate_timestamp).returns("12345")    
    @consumer = OAuthConsumer.new('key', 'secret', :site => 'http://localhost:3001/', :scheme => :header)
  end
  
  def test_basic_setup
    consumer = OAuthConsumer.new('key', 'secret')
    assert_equal 'key', consumer.key
    assert_equal 'secret', consumer.secret
  end
  
  def test_setup_with_options
    assert_equal 'http://localhost:3001/', @consumer.site
    assert_equal :header, @consumer.scheme
  end
  
  def test_customizable_paths
    consumer = OAuthConsumer.new('key', 'secret', 
      :site => 'http://oauth.example', 
      :request_token_path   => '/oauth/example/req.php',
      :access_token_path    => '/oauth/example/token.php',
      :authorize_path       => '/oauth/example/auth.php')
    assert_equal  '/oauth/example/req.php', consumer.request_token_path
    assert_equal  '/oauth/example/token.php', consumer.access_token_path
    assert_equal  '/oauth/example/auth.php', consumer.authorize_path
    assert_equal  'http://oauth.example/oauth/example/req.php', consumer.request_token_url
  end
  
  def test_aquire_request_token
    http_request = mock('HTTP request')
    http_request.expects(:get).with('http://localhost:3001/oauth/request_token', {'Authorization' => 'OAuth realm=, oauth_consumer_key=key, oauth_nonce=nonce, oauth_signature=eff4QrcF%2BzToX7GI4eHYsdc7wfo%3D, oauth_signature_method=HMAC-SHA1, oauth_timestamp=12345, oauth_version=1.0'}).returns('oauth_token=token&oauth_token_secret=top_secret')
    @consumer.stubs(:http).returns(http_request)
    token = @consumer.get_request_token
    assert_kind_of OAuthToken, token
  end
end
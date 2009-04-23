require File.join(File.dirname(__FILE__), 'test_helper')
class CompatRegressionTest < Test::Unit::TestCase
  def setup
    OAuthRequest.stubs(:generate_nonce).returns("225579211881198842005988698334675835446")
    OAuthRequest.stubs(:generate_timestamp).returns("1199645624")    
    @consumer = OAuthConsumer.new('consumer_key_86cad9', '5888bf0345e5d237', 
      :site => 'http://blabla.bla', 
      :scheme => :header, 
      :request_token_path => '/oauth/example/request_token.php',
      :access_token_path  => '/oauth/example/access_token.php',
      :authorize_path     => '/oauth/example/authorize.php'
      )
    @request = OAuthRequest.new(
      :http_method => :GET, 
      :parameters => {})
    @token = OAuthToken.new('token_411a7f', '3196ffd991c8ebdb')
    @request_uri = URI.parse('http://example.com/test?key=value')
  end
  
  def test_initializer
    assert_equal 'consumer_key_86cad9', @consumer.key
    assert_equal '5888bf0345e5d237', @consumer.secret
    assert_equal 'http://blabla.bla', @consumer.site
    assert_equal "/oauth/example/request_token.php",@consumer.request_token_path
    assert_equal "/oauth/example/access_token.php",@consumer.access_token_path
    assert_equal "http://blabla.bla/oauth/example/request_token.php",@consumer.request_token_url
    assert_equal "http://blabla.bla/oauth/example/access_token.php",@consumer.access_token_url
    assert_equal "http://blabla.bla/oauth/example/authorize.php",@consumer.authorize_url
    assert_equal :header,@consumer.scheme
  end
  
  def test_defaults
    @consumer=OAuthConsumer.new(
      "key",
      "secret",
      {
          :site=>"http://twitter.com"
      })
    assert_equal "key",@consumer.key
    assert_equal "secret",@consumer.secret
    assert_equal "http://twitter.com",@consumer.site
    assert_equal "/oauth/request_token",@consumer.request_token_path
    assert_equal "/oauth/access_token",@consumer.access_token_path
    assert_equal "http://twitter.com/oauth/request_token",@consumer.request_token_url
    assert_equal "http://twitter.com/oauth/access_token",@consumer.access_token_url
    assert_equal "http://twitter.com/oauth/authorize",@consumer.authorize_url
    assert_equal :header,@consumer.scheme
  end

  def test_override_paths
    @consumer=OAuthConsumer.new(
      "key",
      "secret",
      {
          :site=>"http://twitter.com",
          :request_token_url=>"http://oauth.twitter.com/request_token",
          :access_token_url=>"http://oauth.twitter.com/access_token",
          :authorize_url=>"http://site.twitter.com/authorize"
      })
    assert_equal "key",@consumer.key
    assert_equal "secret",@consumer.secret
    assert_equal "http://twitter.com",@consumer.site
    assert_equal "/oauth/request_token",@consumer.request_token_path
    assert_equal "/oauth/access_token",@consumer.access_token_path
    assert_equal "http://oauth.twitter.com/request_token",@consumer.request_token_url
    assert_equal "http://oauth.twitter.com/access_token",@consumer.access_token_url
    assert_equal "http://site.twitter.com/authorize",@consumer.authorize_url
    assert_equal :header,@consumer.scheme
  end
  
  # http://developer.netflix.com/resources/OAuthTest
  def test_google_regressions_without_parameters
    OAuthRequest.stubs(:generate_nonce).returns("nonce")
    OAuthRequest.stubs(:generate_timestamp).returns("12345")    
    @consumer = OAuthConsumer.new('key', 'secret')
    @token = OAuthToken.new('foo', 'bar')
    @request = OAuthRequest.from_consumer_and_token(@consumer, @token, 'http://oauth.example.com/do_oauth')
    @request.sign_request(OauthSignatureMethodHMAC_SHA1, @token)
    assert_equal 'http://oauth.example.com/do_oauth?oauth_consumer_key=key&oauth_nonce=nonce&oauth_signature=WZIO8HdSZy%2B6PKEkgrB8ZyqykT8%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=12345&oauth_token=foo&oauth_version=1.0', @request.to_url
  end

  # http://developer.netflix.com/resources/OAuthTest
  def test_google_regressions_with_parameters
    OAuthRequest.stubs(:generate_nonce).returns("nonce")
    OAuthRequest.stubs(:generate_timestamp).returns("12345")    
    @consumer = OAuthConsumer.new('key', 'secret')
    @token = OAuthToken.new('foo', 'bar')
    @request = OAuthRequest.from_consumer_and_token(@consumer, @token, 'http://oauth.example.com/do_oauth', {'foo' => 'bar'})
    @request.sign_request(OauthSignatureMethodHMAC_SHA1, @token)
    assert_equal 'http://oauth.example.com/do_oauth?foo=bar&oauth_consumer_key=key&oauth_nonce=nonce&oauth_signature=xNxW8DDE4TXvTg9cXul7mSfDKeQ%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=12345&oauth_token=foo&oauth_version=1.0', @request.to_url
  end
  
end

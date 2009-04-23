require File.join(File.dirname(__FILE__), 'test_helper')

class TokenTest < Test::Unit::TestCase
  def test_to_s
    t = OAuthSimple::Token.new("key", "secret")
    assert_equal("oauth_token=key&oauth_token_secret=secret", t.to_s)
  end
  
  def test_parse_from_string
    t = OAuthSimple::Token.from_string("oauth_token=key&oauth_token_secret=secret")
    assert_equal("key", t.key)
    assert_equal("secret", t.secret)
  end
  
  def test_authorize_url
    OAuthSimple::Request.stubs(:generate_nonce).returns("nonce")
    OAuthSimple::Request.stubs(:generate_timestamp).returns("12345")
    consumer = OAuthSimple::Consumer.new('key', 'secret', :site => 'http://oauth.local/')
    request_token = OAuthSimple::Token.from_string('oauth_token=key&oauth_token_secret=secret')
    request_token.consumer = consumer
    result = request_token.authorize_url
    assert_equal 'http://oauth.local/oauth/authorize?oauth_consumer_key=key&oauth_nonce=nonce&oauth_timestamp=12345&oauth_token=key&oauth_version=1.0', result
  end
end
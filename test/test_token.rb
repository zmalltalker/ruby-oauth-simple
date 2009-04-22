require File.join(File.dirname(__FILE__), 'test_helper')

class TokenTest < Test::Unit::TestCase
  def test_to_s
    t = OAuthToken.new("key", "secret")
    assert_equal("oauth_token=key&oauth_token_secret=secret", t.to_s)
  end
  
  def test_parse_from_string
    t = OAuthToken.from_string("oauth_token=key&oauth_token_secret=secret")
    assert_equal("key", t.key)
    assert_equal("secret", t.secret)
  end
end
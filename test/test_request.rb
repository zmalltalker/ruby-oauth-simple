require File.join(File.dirname(__FILE__), 'test_helper')

class RequestTest < Test::Unit::TestCase
  def setup
    @request = OAuthRequest.new(:parameters => {'foo' => 'bar', 'oauth_bar' => 'baz', 'oauth_auth' => 'auth'},
      :http_url => 'http://oauth.example.com/do_oauth')
    @consumer = OAuthConsumer.new "key", "secret"
    OAuthRequest.stubs(:generate_nonce).returns("nonce")
    OAuthRequest.stubs(:generate_timestamp).returns("12345")
  end

  def test_non_oauth_parameters
    assert_equal({'foo' => 'bar'}, @request.get_nonoauth_parameters)
  end
  
  def test_oauth_headers
    assert_equal({'Authorization' => "OAuth realm=, oauth_auth=auth, oauth_bar=baz"}, @request.to_header)
  end
  
  def test_postdata
    assert_equal("foo=bar&oauth_auth=auth&oauth_bar=baz", @request.to_postdata)
  end
  
  def test_normalized_http_url
    #assert_equal("http://oauth.example.com/do_oauth", @request.get_normalized_http_url)
  end
  
  def test_normalized_parameters
    assert_equal("foo=bar&oauth_auth=auth&oauth_bar=baz", @request.get_normalized_parameters)
  end
  
  def test_sign_request
    @request.consumer = @consumer
    @request.sign_request(OauthSignatureMethodHMAC_SHA1, nil)
    assert_equal "ZGS1JOGXvCVp44HXaPXJt1HELkg=", @request.get_parameter("oauth_signature")
  end
  
  def test_build_signature
    @request.consumer = @consumer
    assert_nothing_raised do
      sig = @request.build_signature(OauthSignatureMethodHMAC_SHA1)
    end
  end
  
  def test_generate_and_sign_access_token
    access_token = OAuthToken.from_string("oauth_token=foo&oauth_token_secret=bar")
    @request.consumer = @consumer
    @request.sign_request(OauthSignatureMethodHMAC_SHA1, access_token)
    assert_equal 'http://oauth.example.com:80/do_oauth?foo=bar&oauth_auth=auth&oauth_bar=baz&oauth_consumer_key=key&oauth_nonce=nonce&oauth_signature=z0%2B99r08nj11MCRYV%2Bny29g%2FoTc%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=12345&oauth_version=1.0', @request.to_url
  end
  
  def test_generation_of_authorization_url
    request_token = OAuthToken.from_string("oauth_token=foo&oauth_token_secret=bar")
    @request.consumer = @consumer
    @request.sign_request(OauthSignatureMethodHMAC_SHA1, request_token)
    assert_equal({"foo"=>"bar",
     "oauth_auth"=>"auth",
     "oauth_bar"=>"baz",
     "oauth_consumer_key"=>"key",
     "oauth_nonce"=>"nonce",
     "oauth_signature"=>"z0+99r08nj11MCRYV+ny29g/oTc=",
     "oauth_signature_method"=>"HMAC-SHA1",
     "oauth_timestamp"=>"12345",
     "oauth_version"=>"1.0"}, @request.postdata_hash)
  end
end
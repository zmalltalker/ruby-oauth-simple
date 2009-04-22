class OAuthToken
  attr_reader :key, :secret
  def initialize(key, secret)
    @key = key
    @secret = secret
  end
  
  def to_s
    "oauth_token=#{CGI.escape(@key)}&oauth_token_secret=#{CGI.escape(@secret)}"
  end
  
  def self.from_string(str)
    params = CGI.parse(str)
    return new(params['oauth_token'].first, params['oauth_token_secret'].first)
  end
  
  # In order to have a token generate a URL, it needs to know of its consumer.
  # Doesn't look quite right to have it here, but the way the API works...
  def consumer=(c)
    @consumer = c
  end
  
  def authorize_url
    req = OAuthRequest.from_consumer_and_token(@consumer, self, @consumer.authorize_url, {})
    return req.to_url
  end
  
  def get_access_token
    request = OAuthRequest.from_consumer_and_token(@consumer, self, @consumer.access_token_url)
    request.consumer = @consumer
    request.sign_request(OauthSignatureMethodHMAC_SHA1, self)
    response = open(request.get_normalized_http_url, 'r', request.to_header).read
    return OAuthToken.from_string(response)
  end
end
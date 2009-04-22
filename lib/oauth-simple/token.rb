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
end
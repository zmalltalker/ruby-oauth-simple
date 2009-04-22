class OAuthConsumer
  attr_reader :key, :secret
  def initialize(key, secret, options = {})
    @key = key
    @secret = secret
    @options = self.class.default_options.merge(options)
  end
  
  # Default options, can be overridden in the initializer's options hash
  def self.default_options
    {
      :scheme             => :header,
      :authorize_path     => '/oauth/authorize',
      :access_token_path  => '/oauth/access_token',
      :request_token_path => '/oauth/request_token'
    }
  end
  
  def site
    @options[:site]
  end
  
  def scheme
    @options[:scheme]
  end
  
  def authorize_path
    @options[:authorize_path]
  end
  
  def access_token_path
    @options[:access_token_path]
  end
  
  def request_token_path
    @options[:request_token_path]
  end
  
  def request
    result = OAuthRequest.new(:http_url => request_token_url)
    result.consumer = self
    result
  end

  def http
    OAuthHttpClient.new
  end
  
  def get_request_token
    r = request
    r.sign_request(OauthSignatureMethodHMAC_SHA1)
#    raise r.to_header.inspect
    response = http.get(request_token_url, r.to_header)
    result = OAuthToken.from_string(response)
    result.consumer = self
    return result
  end
  
  def request_token_url
    File.join(site, request_token_path)
  end
  
  def access_token_url
    File.join(site, access_token_path)
  end
  
  def authorize_url
    File.join(site, authorize_path)
  end
end

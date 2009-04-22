class OAuthConsumer
  attr_reader :key, :secret
  def initialize(key, secret, options = {})
    @key = key
    @secret = secret
    @options = options.merge(self.class.default_options)
  end
  
  def self.default_options
    {:scheme => :header}
  end
  
  def site
    @options[:site]
  end
  
  def scheme
    @options[:scheme]
  end
end

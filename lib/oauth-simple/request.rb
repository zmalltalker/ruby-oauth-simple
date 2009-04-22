class OAuthRequest
  VERSION = "1.0"
  attr_reader :consumer
  def initialize(options={})
    @http_method = options[:http_method] || :GET
    @http_url = options[:http_url]
    @parameters = options[:parameters] || {}
  end
  
  def consumer=(consumer)
    set_parameter('oauth_consumer_key', consumer.key)
    set_parameter('oauth_timestamp', self.class.generate_timestamp)
    set_parameter('oauth_nonce', self.class.generate_nonce)
    set_parameter('oauth_version', VERSION)
    @consumer = consumer
  end
  
  def set_parameter(k, v)
    @parameters[k] = v
  end
  
  def get_parameter(k)
    @parameters[k]
  end
  
  def _get_timestamp_nonce
    [@parameters[:oauth_timestamp], @parameters[:oauth_nonce]]
  end
  
  def get_nonoauth_parameters
    @parameters.reject{|k,v| k =~ /^oauth_.*/}
  end
  
  def to_header(realm="")
    auth_header = "OAuth "
    pairs = ["realm=#{realm}"]
    @parameters.sort.each do |k, v|
      if k =~ /^oauth_/
        pairs << "#{k}=#{CGI.escape(v)}"
      end
    end
    auth_header << pairs.join(", ")
    return {"Authorization" => auth_header}
  end

  def postdata_hash
    result = {}
    @parameters.sort.each do |k,v|
      result[k] = v
    end
    result
  end
  
  def to_postdata
    result = []
    @parameters.sort.each do |key, value|
      result << "#{CGI.escape(key)}=#{CGI.escape(value)}"
    end
    return result.join("&")
  end
  
  def to_url
    return "#{get_normalized_http_url}?#{to_postdata}"
  end
  
  def get_normalized_http_url
    parts = URI.parse(@http_url)
    return "#{parts.scheme}://#{parts.host}:#{parts.port}#{parts.path}"
  end
  
  def get_normalized_http_method
    return @http_method.to_s.upcase
  end
  
  def get_normalized_parameters
    @parameters.sort.map do |k, values|
      if values.is_a?(Array)
        # multiple values were provided for a single key
        values.sort.collect do |v|
          [CGI.escape(k),CGI.escape(v)] * "="
        end
      else
        [CGI.escape(k),CGI.escape(values)] * "="
      end
    end * "&"    
  end

  def self.from_consumer_and_token(consumer, token, url, options = {})
    defaults = {
      'oauth_consumer_key' => consumer.key,
      'oauth_timestamp' => generate_timestamp,
      'oauth_nonce' => generate_nonce,
      'oauth_version' => VERSION
    }
    defaults.merge(options)
    instance = new(:http_url => url, :parameters => defaults)
    instance.set_parameter('oauth_token', token.key) if token
    instance.consumer = consumer
    return instance
  end
  
  def self.generate_timestamp
    return Time.now.to_i.to_s
  end
  
  def self.generate_nonce(size=32)
    bytes = OpenSSL::Random.random_bytes(size)
    [bytes].pack('m').gsub(/\W/,'')
  end

  def sign_request(signature_klass, token=nil)
    raise "Consumer is nothing" if @consumer.nil?
    set_parameter('oauth_signature_method', signature_klass.oauth_name)
    set_parameter('oauth_signature', build_signature(signature_klass, token))
  end
  
  def build_signature(signature_klass, token=nil)
    return signature_klass.build_signature(self, consumer, token)
  end
end

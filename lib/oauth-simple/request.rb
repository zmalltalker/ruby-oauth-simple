# The MIT License
# 
# Copyright (c) 2009 Marius Mathiesen <marius.mathiesen@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
module OAuthSimple
  class Request
    VERSION = "1.0"
    attr_accessor :consumer
    def initialize(options={})
      @http_method = options[:http_method] || :GET
      @http_url = options[:http_url]
      @parameters = options[:parameters] || {}
    end
  
    # Builds a request from a consumer and (optionally) a token
    def self.from_consumer_and_token(consumer, token, url, options = {})
      defaults = {
        'oauth_consumer_key' => consumer.key,
        'oauth_timestamp' => generate_timestamp,
        'oauth_nonce' => generate_nonce,
        'oauth_version' => VERSION
      }
      options.merge!(defaults)
      instance = new(:http_url => url, :parameters => options)
      instance.set_parameter('oauth_token', token.key) if token
      instance.consumer = consumer
      return instance
    end
  
    # For testing with a known timestamp and nonce
    def override_timestamp_and_nonce(timestamp, nonce)
      set_parameter('oauth_timestamp', timestamp)
      set_parameter('oauth_nonce', nonce)
    end
  
    def set_parameter(k, v)
      @parameters[k] = v
    end
  
    def get_parameter(k)
      @parameters[k]
    end
  
    def get_nonoauth_parameters
      @parameters.reject{|k,v| k =~ /^oauth_.*/}
    end
  
    def to_header(realm=nil)
      auth_header = "OAuth "
      pairs = []
      pairs  << "realm=#{realm}" 
      @parameters.sort.each do |k, v|
        if k =~ /^oauth_/
          pairs << "#{k}=\"#{CGI.escape(v)}\""
        end
      end
      auth_header << pairs.join(",")
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
      if parts.port == 80
        return "#{parts.scheme}://#{parts.host}#{parts.path}"
      else
        return "#{parts.scheme}://#{parts.host}:#{parts.port}#{parts.path}"
      end
    end
  
    def get_normalized_http_method
      return @http_method.to_s.upcase
    end
  
    def get_normalized_parameters
      @parameters.reject{|k,v|k=='oauth_signature'}.sort.map do |k, values|
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
end
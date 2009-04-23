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
  class Consumer
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
        :request_token_path => '/oauth/request_token',
        :signature_method   => 'HMAC-SHA1'
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
  
    def http
      HttpClient.new
    end
    
    def signature_method
      SignatureMethod.by_name(@options[:signature_method])
    end
  
    def get_request_token
      r = Request.from_consumer_and_token(self, nil, request_token_url)
      r.sign_request(signature_method)
      response = http.get(request_token_url, r.to_header)
      result = Token.from_string(response)
      result.consumer = self
      return result
    end
  
    def request_token_url
      @options[:request_token_url] || File.join(site, request_token_path)
    end
  
    def access_token_url
      @options[:access_token_url] || File.join(site, access_token_path)
    end
  
    def authorize_url
      @options[:authorize_url] || File.join(site, authorize_path)
    end
  end
end
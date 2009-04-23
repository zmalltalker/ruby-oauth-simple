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
  class Token
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
      req = Request.from_consumer_and_token(@consumer, self, @consumer.authorize_url, {})
      return req.to_url
    end
  
    def get_access_token
      request = Request.from_consumer_and_token(@consumer, self, @consumer.access_token_url)
      request.consumer = @consumer
      request.sign_request(SignatureMethodHMAC_SHA1, self)
      response = open(request.get_normalized_http_url, 'r', request.to_header).read
      return Token.from_string(response)
    end
  end
end
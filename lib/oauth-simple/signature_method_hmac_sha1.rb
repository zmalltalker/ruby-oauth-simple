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
  class SignatureMethodHMACSHA1 < SignatureMethod
    def self.oauth_name
      "HMAC-SHA1"
    end
  
    def self.build_signature_base_string(request, consumer, token)
      sig = [
        CGI.escape(request.get_normalized_http_method),
        CGI.escape(request.get_normalized_http_url),
        CGI.escape(request.get_normalized_parameters)
      ]
      key = "#{CGI.escape(consumer.secret)}&"
      key << CGI.escape(token.secret) if token
      raw = sig.join("&")
      return [key, raw]
    end
  
    def self.build_signature(request, consumer, token)
      key, raw = build_signature_base_string(request, consumer, token)
      hashed = calculate_digest(key, raw)
      return [hashed].pack('m').chomp.gsub(/\n/, '')
    end
    
    def self.calculate_digest(key, data)
      if RUBY_VERSION >= "1.9"
        Digest::HMAC.new(key, Digest::SHA1).digest(data)
      else
        ::HMAC::SHA1.digest(key, data)
      end
    end
  end
end
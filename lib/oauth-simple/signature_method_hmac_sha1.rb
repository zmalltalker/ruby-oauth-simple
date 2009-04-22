class OauthSignatureMethodHMAC_SHA1 < OAuthSignatureMethod
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
    hashed = Digest::HMAC.new(key, Digest::SHA1).digest(raw)
    return [hashed].pack('m').chomp.gsub(/\n/, '')
  end
end
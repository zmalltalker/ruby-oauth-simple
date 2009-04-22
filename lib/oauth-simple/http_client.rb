require 'open-uri'
# A simplistic client that performs HTTP operations
class OAuthHttpClient
  def get(url, headers)
    open(url, 'r', headers).read
  end
end
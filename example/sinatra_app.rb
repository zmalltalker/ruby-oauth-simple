require File.join(File.dirname(__FILE__), '../lib/oauth-simple')

require 'open-uri'
require 'rubygems'
require 'sinatra'
require 'json'

SITE = 'http://localhost:3001'
KEY = '5rru7RgENgeL5uIWMETEA'
SECRET = 'qj6GVeKFssJxmxT77sSasC4mXJebl2EvWNSEnVoI'
VERIFICATION_URL = 'http://localhost:3001/users.json'


get '/' do
  erb :index
end

get '/goto_oauth' do
  $consumer = OAuthConsumer.new(KEY, SECRET, 
    :site => SITE, 
    :scheme => :GET)
  $request_token = $consumer.get_request_token
  redirect $request_token.authorize_url
end

get '/oauth_return' do
  access_token = $request_token.get_access_token
  
  # Meh, this is as far as I got

  fourth_request = OAuthRequest.from_consumer_and_token($consumer, access_token, VERIFICATION_URL)
  fourth_request.consumer = $consumer
  fourth_request.sign_request(OauthSignatureMethodHMAC_SHA1, access_token)
  
  @result = open(fourth_request.get_normalized_http_url, 'r', fourth_request.to_header).read
  erb :result
end
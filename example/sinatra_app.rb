require File.join(File.dirname(__FILE__), '../lib/oauth-simple')

require 'open-uri'
require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

get '/goto_oauth' do
  $consumer = OAuthConsumer.new('KGpBROtLfxyKHFh9iMtTA','zENnjjk1e1EQODcrE8zRqK3Kty2XUqeqbNHoWEWCFDo')
  request = OAuthRequest.new(:http_url => 'http://localhost:3001/oauth/request_token')
  request.consumer = $consumer
  request.sign_request(OauthSignatureMethodHMAC_SHA1)
  res = open('http://localhost:3001/oauth/request_token', 'r', request.to_header).read
  $request_token = OAuthToken.from_string(res)
  debug_output = ""
  debug_output << "Got request token: #{$request_token}"
  second_request = OAuthRequest.from_consumer_and_token($consumer, $request_token, 'http://localhost:3001/oauth/authorize', {})
  debug_output << "Authorization url is #{second_request.to_url}"
  redirect second_request.to_url
end

get '/returning_from_oauth' do
  request = OAuthRequest.from_consumer_and_token($consumer, $request_token, 'http://localhost:3001/oauth/access_token')
  request.consumer = $consumer
  request.sign_request(OauthSignatureMethodHMAC_SHA1, $request_token)
  response = open(request.get_normalized_http_url, 'r', request.to_header).read

  access_token = OAuthToken.from_string(response)

  "Yeah. Got access token: #{access_token}"
  
  fourth_request = OAuthRequest.from_consumer_and_token($consumer, access_token, 'http://localhost:3001/merge_requests.xml')
  fourth_request.consumer = $consumer
  fourth_request.sign_request(OauthSignatureMethodHMAC_SHA1, access_token)
  
  response = open(fourth_request.get_normalized_http_url, 'r', fourth_request.to_header).read
  response
end
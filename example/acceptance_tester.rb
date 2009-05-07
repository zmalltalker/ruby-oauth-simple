require File.join(File.dirname(__FILE__), '../lib/oauth-simple')
require 'oauth'

require 'rubygems'
require 'sinatra'


get '/' do
  erb :'test_start_page'
end

post '/preview' do
  @result = {
    :oauth_simple => oauth_simple_parameters,
    :oauth_gem    => oauth_gem_parameters
  }
  erb :'test_start_page'
end

def oauth_simple_parameters
  consumer = OAuthSimple::Consumer.new(params['consumer_key'], params['consumer_secret'], :site => params['url'])
  if params['token_key'] == ""
    token = nil
  else
    token = OAuthSimple::Token.new(params['token_key'], params['token_secret'])
  end
  oauth_parameters = request_params
  request = OAuthSimple::Request.from_consumer_and_token(consumer, token, params['url'], oauth_parameters)
  request.override_timestamp_and_nonce(params['timestamp'], params['nonce'])
  
  request.sign_request(consumer.signature_method, token)
  
  return {
    :normalized_parameters    => request.get_normalized_parameters,
    :signature_base_string    => consumer.signature_method.build_signature_base_string(request, consumer, token)[1],
    :signature                => request.get_parameter('oauth_signature'),
    :header                   => request.to_header['Authorization']
  }
end

def oauth_gem_parameters
  consumer = OAuth::Consumer.new(params['consumer_key'], params['consumer_secret'], :site => params['url'])
  consumer_token = OAuth::ConsumerToken.new(consumer, params['token_key'], params['token_secret'])
  request_uri = URI.parse(params['url'])
  request_parameters = request_params
  nonce = params['nonce']
  timestamp = params['timestamp']
  consumer.http=Net::HTTP.new(request_uri.host, request_uri.port)
  
  oauth_request = Net::HTTP::Get.new(request_uri.path + "?" + params['oauth_parameters'])
#  oauth_request = Net::HTTP::Get.new(request_uri.path)
  
  
  consumer_token.sign!(oauth_request, {:nonce => nonce, :timestamp => timestamp})  
  {
    :signature_base_string => oauth_request.oauth_helper.signature_base_string.inspect,
    :header => oauth_request['Authorization'],
    :normalized_parameters => oauth_request.normalized_parameters
  }
end

def request_params
  if params['oauth_parameters'] == ''
    oauth_parameters = {}
  else
    key_and_values = params['oauth_parameters'].split('&')
    oauth_parameters = {}
    key_and_values.each do |pp|
      key, value = pp.split("=")
      oauth_parameters[key] = CGI.escape(value)
    end
  end
  return oauth_parameters
end
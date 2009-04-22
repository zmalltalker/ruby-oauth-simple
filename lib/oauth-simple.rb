require 'cgi'
require 'uri'
require 'digest/hmac'
require 'openssl'
$:.unshift(File.dirname(__FILE__))
require 'oauth-simple/common'
require 'oauth-simple/consumer'
require 'oauth-simple/request'
require 'oauth-simple/token'
require 'oauth-simple/signature_method'
require 'oauth-simple/signature_method_hmac_sha1'




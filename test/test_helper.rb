require File.join(File.dirname(__FILE__), '../lib/oauth-simple')
require 'test/unit'
require 'mocha'
module Test
  module Unit
    class TestCase
      PASSTHROUGH_EXCEPTIONS = [] unless defined?(PASSTHROUGH_EXCEPTIONS)
    end
  end
end
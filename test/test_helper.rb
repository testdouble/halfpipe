$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "halfpipe"

require "minitest/autorun"

class UnitTest < Minitest::Test
  def setup
    Halfpipe.config(api_token: nil, subdomain: nil)
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "halfpipe"
require "dotenv/load"

require "minitest/autorun"

class UnitTest < Minitest::Test
  def setup
    Halfpipe.config(api_token: nil, subdomain: nil, debug: false)
  end
end

class SafeTest < Minitest::Test
  def setup
    Halfpipe.config(
      api_token: ENV["PIPEDRIVE_API_KEY"],
      subdomain: ENV["PIPEDRIVE_SUBDOMAIN"],
      debug: ENV["DEBUG"]
    )
  end
end

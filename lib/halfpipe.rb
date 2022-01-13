require_relative "halfpipe/version"
require_relative "halfpipe/config"

module Halfpipe
  class Error < StandardError; end

  def self.config(**attrs)
    (@config ||= Config.new).tap do |config|
      config.set(**attrs)
    end
  end
end

module Halfpipe
  module Log
    def self.debug(msg)
      return unless Halfpipe.config.debug
      puts msg
    end
  end
end

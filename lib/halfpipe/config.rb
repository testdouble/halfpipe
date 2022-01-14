module Halfpipe
  class Config
    attr_accessor :api_token, :subdomain, :debug

    def initialize
      @debug = false
    end

    def set(**attrs)
      @api_token = attrs[:api_token] if attrs.key?(:api_token)
      @subdomain = attrs[:subdomain] if attrs.key?(:subdomain)
      @debug = attrs[:debug] if attrs.key?(:debug)
    end
  end
end

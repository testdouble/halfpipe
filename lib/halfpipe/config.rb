module Halfpipe
  class Config
    attr_accessor :api_token, :subdomain

    def set(**attrs)
      @api_token = attrs[:api_token] if attrs.key?(:api_token)
      @subdomain = attrs[:subdomain] if attrs.key?(:subdomain)
    end
  end
end

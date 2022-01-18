require "net/http"
require "json"

module Halfpipe
  module Http
    def self.get(path, params: {}, start: 0)
      uri = URI(url_for(path))
      uri.query = URI.encode_www_form(params.merge(
        api_token: Halfpipe.config.api_token,
        start: start
      ))
      Log.debug("GETting #{uri}")
      res = Net::HTTP.get_response(uri)
      json = parse_json(res)

      if rate_limited?(res)
        wait_time = res["x-ratelimit-reset"].to_i
        puts "Reached rate limit, sleeping #{wait_time}"
        sleep wait_time
        get(path, params: params, start: start)
      else
        raise_failure_maybe!(res, json)

        # Search results are not on data, but data.items
        results = if !json["data"].respond_to?(:key?) || !json["data"]&.key?("items")
          json["data"]
        else
          json.dig("data", "items")
        end

        if json.dig("additional_data", "pagination", "more_items_in_collection")
          results += get(
            path,
            params: params,
            start: json.dig("additional_data", "pagination", "next_start")
          )
        end
        results
      end
    end

    def self.post(path, params: {})
      uri = URI("#{url_for(path)}?api_token=#{Halfpipe.config.api_token}")
      Log.debug("POSTing #{uri} with: #{params.inspect}")
      res = Net::HTTP.post_form(uri, params)
      json = parse_json(res)
      raise_failure_maybe!(res, json)
      json["data"]
    end

    def self.delete(path, params: {})
      http = Net::HTTP.new("#{Halfpipe.config.subdomain}.pipedrive.com", 443)
      http.use_ssl = true
      query = URI.encode_www_form(params.merge(
        api_token: Halfpipe.config.api_token
      ))
      path = "/api/v1#{path}?#{query}"
      Log.debug("DELETEing #{path}")
      res = http.delete(path)
      unless res.is_a?(Net::HTTPSuccess)
        raise Error.new <<~MSG
          Deletion of #{path.inspect} failed with #{res.code}:

          #{res.body}
        MSG
      end
    end

    class << self
      private

      def url_for(path)
        "https://#{Halfpipe.config.subdomain}.pipedrive.com/api/v1#{path}"
      end

      def parse_json(res)
        JSON.parse(res.body)
      rescue
        nil
      end

      def rate_limited?(res)
        res.code == "429" || res["x-ratelimit-remaining"].to_i < 1
      end

      def raise_failure_maybe!(res, json)
        return if res.is_a?(Net::HTTPSuccess) && json&.fetch("success")
        raise Error.new <<~MSG
          Pipedrive request failed with status code #{res.code}

          Response body:
          #{json.inspect}
        MSG
      end
    end
  end
end

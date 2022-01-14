module Halfpipe
  module Api
    module DealFields
      def self.get
        Http.get("/dealFields").map { |json|
          DealField.new(
            key: json["key"],
            name: json["name"],
            symbol: Halfpipe::Strings.deform(json["name"])
          )
        }
      end
    end
  end
end

module Halfpipe
  module Api
    module Stages
      def self.find_first_stage_by_pipeline_name(pipeline_name)
        json = Http.get("/stages").select { |json|
          json["pipeline_name"] == pipeline_name
        }.min_by { |json| json["order_nr"] }

        unless json.nil?
          Stage.new(
            id: json["id"],
            pipeline_id: json["pipeline_id"],
            name: json["name"]
          )
        end
      end
    end
  end
end

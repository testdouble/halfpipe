require_relative "deal_fields"

module Halfpipe
  module Api
    module Deals
      def self.create(title:, stage_id: nil, person_id: nil, organization_id: nil, custom_fields: {})
        pipedrive_keyed_custom_fields = map_custom_fields(custom_fields)
        json = Http.post("/deals", params: {
          title: title,
          stage_id: stage_id,
          person_id: person_id,
          org_id: organization_id
        }.merge(pipedrive_keyed_custom_fields).compact)

        Deal.new(
          id: json["id"],
          stage_id: json["stage_id"],
          person_id: json.dig("person_id", "value"),
          organization_id: json.dig("org_id", "value"),
          title: title
        )
      end
      class << self
        private

        def map_custom_fields(custom_fields)
          pipedrive_fields = DealFields.get
          custom_fields.map { |name, value|
            pipedrive_field = pipedrive_fields.find { |pipedrive_field|
              pipedrive_field.name == name
            } || pipedrive_fields.find { |pipedrive_field|
              pipedrive_field.name == Halfpipe::Strings.deform(name)
            }
            if pipedrive_field.nil?
              raise Error.new <<~MSG
                Failed to find custom deal field in Pipedrive named #{name.inspect}
              MSG
            end
            [pipedrive_field.key, value]
          }.to_h
        end
      end
    end
  end
end

module Halfpipe
  module Api
    module Notes
      def self.create(content:, deal_id: nil, person_id: nil, organization_id: nil)
        json = Http.post("/notes", params: {
          content: content,
          deal_id: deal_id,
          person_id: person_id,
          org_id: organization_id
        })
        Note.new(
          id: json["id"],
          content: content,
          deal_id: deal_id,
          person_id: person_id,
          organization_id: organization_id
        )
      end
    end
  end
end

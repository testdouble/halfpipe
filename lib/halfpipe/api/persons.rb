module Halfpipe
  module Api
    module Persons
      def self.find_by_email(email)
        json = Http.get("/persons/search", params: {
          term: email,
          fields: "email",
          exact_match: true
        }).first&.fetch("item")

        unless json.nil?
          Person.new(
            id: json["id"],
            name: json["name"],
            email: email,
            organization_id: json.dig("organization", "id")
          )
        end
      end

      def self.create(name:, email:)
        json = Http.post("/persons", params: {
          name: name,
          email: email
        })

        Person.new(
          id: json["id"],
          name: json["name"],
          email: email
        )
      end
    end
  end
end

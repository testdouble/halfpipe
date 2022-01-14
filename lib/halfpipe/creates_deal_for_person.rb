require_relative "api/persons"
require_relative "api/stages"
require_relative "api/deals"
require_relative "api/notes"

module Halfpipe
  class CreatesDealForPerson
    Result = Struct.new(:stage, :person, :deal, :note, keyword_init: true)

    def call(
      name:, email:, deal_title:,
      custom_deal_fields:, note_content:, pipeline_name:
    )
      stage = Api::Stages.find_first_stage_by_pipeline_name(pipeline_name)
      person = find_or_create_person(name: name, email: email)
      deal = Api::Deals.create(
        stage_id: stage.id,
        person_id: person.id,
        organization_id: person.organization_id,
        title: deal_title,
        custom_fields: custom_deal_fields
      )
      unless note_content.nil?
        note = Api::Notes.create(
          content: note_content,
          deal_id: deal.id,
          person_id: person.id,
          organization_id: person.organization_id
        )
      end

      Result.new(
        stage: stage,
        person: person,
        deal: deal,
        note: note
      )
    end

    private

    def find_or_create_person(name:, email:)
      Api::Persons.find_by_email(email) ||
        Api::Persons.create(
          name: name,
          email: email
        )
    end
  end
end

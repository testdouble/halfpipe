require_relative "halfpipe/version"
require_relative "halfpipe/strings"
require_relative "halfpipe/config"
require_relative "halfpipe/log"
require_relative "halfpipe/http"
require_relative "halfpipe/values"
require_relative "halfpipe/creates_deal_for_person"

module Halfpipe
  class Error < StandardError; end

  def self.create_deal_for_person(
    email:, deal_title:, name: nil,
    custom_deal_fields: {}, note_content: nil, pipeline_name: nil
  )
    CreatesDealForPerson.new.call(
      name: name,
      email: email,
      deal_title: deal_title,
      custom_deal_fields: custom_deal_fields,
      note_content: note_content,
      pipeline_name: pipeline_name
    )
  end

  def self.config(**attrs)
    (@config ||= Config.new).tap do |config|
      config.set(**attrs)
    end
  end
end

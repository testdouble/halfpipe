module Halfpipe
  Person = Struct.new(:id, :name, :email, :organization_id, keyword_init: true)
  Stage = Struct.new(:id, :pipeline_id, :name, keyword_init: true)
  Deal = Struct.new(:id, :title, :stage_id, :person_id, :organization_id, keyword_init: true)
  DealField = Struct.new(:key, :name, :symbol, keyword_init: true)
  Note = Struct.new(:id, :content, :deal_id, :person_id, :organization_id, keyword_init: true)
end

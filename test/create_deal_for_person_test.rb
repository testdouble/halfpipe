require "test_helper"

class CreateDealForPersonTest < SafeTest
  # Used to cleanup this test's data:
  PERSON_EMAIL = "person.face@example.com"
  DEAL_TITLE = "Person Face lead via Halfpipe"
  NOTE_CONTENT = "Greetings!"

  def setup
    super
    delete_persons_with_email(PERSON_EMAIL)
    delete_deals_with_title(DEAL_TITLE)
    delete_notes_with_content(NOTE_CONTENT)
  end

  def test_create_deal_for_new_person
    result = Halfpipe.create_deal_for_person(
      name: "Person Face",
      email: PERSON_EMAIL,
      deal_title: DEAL_TITLE,
      custom_deal_fields: {
        "How they heard about us" => "A GitHub README",
        "Inbound CTA" => "halfpipe-github-readme"
      },
      note_content: NOTE_CONTENT,
      pipeline_name: "Test Double Leads"
    )

    refute_nil result.person.id
    refute_nil result.stage.id
    refute_nil result.stage.pipeline_id
    assert_equal "Inbound Leads", result.stage.name
    assert_equal "Person Face", result.person.name
    assert_equal PERSON_EMAIL, result.person.email
    refute_nil result.deal.id
    assert_equal DEAL_TITLE, result.deal.title
    assert_equal result.person.id, result.deal.person_id
    refute_nil result.note.id
    assert_equal NOTE_CONTENT, result.note.content
    assert_equal result.deal.id, result.note.deal_id
    assert_equal result.person.id, result.note.person_id

    # If that looks good, fetch the real thing and verify it went end-to-end
    real_deal = Halfpipe::Http.get("/deals/#{result.deal.id}")
    assert_equal "Person Face", real_deal.dig("person_id", "name")
    assert_equal PERSON_EMAIL, real_deal.dig("person_id", "email", 0, "value")
    assert_equal DEAL_TITLE, real_deal["title"]
    assert_equal result.stage.id, real_deal["stage_id"]
    assert_equal result.stage.pipeline_id, real_deal["pipeline_id"]
    assert real_deal.value?("A GitHub README")
    assert real_deal.value?("halfpipe-github-readme")
    assert 1, real_deal["notes_count"]
  end

  def test_create_deal_for_existing_person
    person = Halfpipe::Api::Persons.create(
      name: "A person",
      email: PERSON_EMAIL
    )
    sleep 2 # This is necessary because Person search is eventually consistent 😆

    result = Halfpipe.create_deal_for_person(
      email: PERSON_EMAIL,
      deal_title: DEAL_TITLE,
      pipeline_name: "Test Double Leads"
    )

    real_deal = Halfpipe::Http.get("/deals/#{result.deal.id}")
    assert_equal person.id, real_deal.dig("person_id", "value")
    assert_equal "A person", real_deal.dig("person_id", "name")
    assert_equal PERSON_EMAIL, real_deal.dig("person_id", "email", 0, "value")
    assert 0, real_deal["notes_count"]
  end

  private

  def delete_persons_with_email(email)
    ids_to_delete = Halfpipe::Http.get("/persons").select { |json|
      json["email"].any? { |json| json["value"] == email }
    }.map { |person| person["id"] }

    unless ids_to_delete.empty?
      Halfpipe::Http.delete("/persons", params: {ids: ids_to_delete.join(",")})
    end
  end

  def delete_deals_with_title(title)
    ids_to_delete = Halfpipe::Http.get("/deals").select { |json|
      json["title"] == title
    }.map { |json| json["id"] }

    unless ids_to_delete.empty?
      Halfpipe::Http.delete("/deals", params: {ids: ids_to_delete.join(",")})
    end
  end

  def delete_notes_with_content(content)
    ids_to_delete = Halfpipe::Http.get("/notes").select { |json|
      json["content"] == content
    }.map { |json| json["id"] }

    ids_to_delete.each do |id|
      Halfpipe::Http.delete("/notes/#{id}")
    end
  end
end

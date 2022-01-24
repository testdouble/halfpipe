require "test_helper"

class InvalidApiKeyTest < SafeTest
  def test_nonsense_key
    Halfpipe.config(api_token: "Silly nonsense key")

    e = assert_raises(Halfpipe::Error) do
      Halfpipe::Api::Persons.find_by_email("lol@nope.com")
    end
    assert_equal "Pipedrive API returned 401 unauthorized. Verify your API token and subdomain?", e.message
  end
end

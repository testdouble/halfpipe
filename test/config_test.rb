require "test_helper"

class ConfigTest < UnitTest
  def test_that_settings_are_unset_by_default
    default_config = Halfpipe.config

    assert_nil default_config.api_token
  end

  def test_that_it_can_store_an_api_token
    Halfpipe.config(api_token: "HAHABUSINESS")

    result = Halfpipe.config

    assert_equal "HAHABUSINESS", result.api_token
    assert_nil result.subdomain
    refute result.debug
  end

  def test_that_it_can_store_an_api_token_and_a_subdomain_and_debug_flag
    Halfpipe.config(api_token: "HAHABUSINESS", subdomain: "memes", debug: true)

    result = Halfpipe.config

    assert_equal "HAHABUSINESS", result.api_token
    assert_equal "memes", result.subdomain
    assert result.debug
  end

  def test_that_it_is_just_a_basic_mutable_instance
    config = Halfpipe.config(api_token: "HAHABUSINESS", subdomain: "memes")
    config.api_token = "LOLNOPE"

    result = Halfpipe.config(subdomain: "www")

    assert_equal "LOLNOPE", result.api_token
    assert_equal "www", result.subdomain
  end
end

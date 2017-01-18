require "minitest/autorun"
require_relative "password_class.rb"

class TestApp < Minitest::Test

    def test_input_username_returns_downcased_username
        username = Password.new("JeReMy")
        assert_equal("jeremy", username.username)
    end

    def test_input_username_must_be_atlest_5_characters_long
        username = Password.new("Bill")
        assert_equal(false, username.username_length_5_character_minimum?)
    end

    def test_input_username_over_5_characters_long
        username = Password.new("Billy5392")
        assert_equal(true, username.username_length_5_character_minimum?)
    end

    # def test_username_must_include_letters?
    #     username = Password.new("Billy5392")
    #     assert_equal(true, username.username_must_include_letters?)
    # end

    def test_password_input_returns_true_and_is_atleast_8_characters_long
        username = Password.new("Billy5392")
        password = "Password"
        assert_equal(true, username.password__length_8_character_minimum?(password))
    end

    def test_password_input_returns_false_and_is_under_8_characters_long
        username = Password.new("Billy5392")
        password = "Pass"
        assert_equal(false, username.password__length_8_character_minimum?(password))
    end

    # def test_password_only_contains_alphanumeric_characters
    #     username = Password.new("Billy5392")
    #     password = "Password"
    #     assert_equal(true, username.password_only_include_letters_and_numbers?(password))
    # end
    
    # def test_password_only_contains_alphanumeric_characters_with_non_alphas
    #     username = Password.new("Billy5392")
    #     assert_equal(false, username.password_only_include_letters_and_numbers?("Password_ -. "))
    # end
end

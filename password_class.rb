class Password
    attr_accessor :password, :username
  
    def initialize(username)
        (@username = username).downcase! #kids may not have an understanding of case system and how it affects usernames, so i just downcase them so as to help have less errors
        @password = ""
    end

    def username_length_5_character_minimum? 
        @username.length >= 5
    end

    # def username_must_include_letters?
    #     username = @username
    #     username = username.to_s
    #     username.include? (/\w/)
    # end

    def password__length_8_character_minimum?(password)
        if password.length > 7
            true
        else
            false
        end
    end

    # def password_only_include_letters_and_numbers?(password)
    #     deleted_characters = @password.gsub(/\W+/, '')
    #     puts deleted_characters
    #     if deleted_characters == @password
    #         true
    #     else
    #         false
    #     end
    # end


end
module RegexpPropertyValues
  def self.characters
    @characters ||= ((0..55_295).to_a + (57_344..1_114_111).to_a)
                    .map { |cp_number| [cp_number].pack('U') }
  end

  module ValueExtension
    def supported_by_current_ruby?
      begin !!regexp; rescue RegexpError, SyntaxError; false end
    end

    def matched_characters
      RegexpPropertyValues.characters.select { |char| regexp.match(char) }
    end

    def regexp
      @regexp ||= /\p{#{self}}/u
    end
  end
end

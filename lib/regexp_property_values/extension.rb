module RegexpPropertyValues
  module Extension
    def supported_by_current_ruby?
      !!regexp
    rescue ArgumentError
      false
    end

    def regexp
      @regexp ||= /\p{#{self}}/u
    rescue RegexpError, SyntaxError
      raise ArgumentError, "Unknown property name #{self}"
    end

    if const_defined?(:OnigRegexpPropertyHelper)
      # C extension loaded

      def matched_codepoints
        matched_ranges.flat_map(&:to_a)
      end

      def matched_ranges
        OnigRegexpPropertyHelper.matched_ranges(self.encode('utf-8'))
      end

      def matched_characters
        matched_codepoints.map { |cp| cp.chr('utf-8') }
      end

      def character_set
        require 'character_set'
        CharacterSet.from_ranges(*matched_ranges)
      end
    else
      # Ruby fallback - this stuff is slow as hell, and it wont get much faster

      def matched_codepoints
        matched_characters.map(&:ord)
      end

      def matched_ranges
        require 'set'
        matched_codepoints
          .to_set(SortedSet)
          .divide { |i, j| (i - j).abs == 1 }
          .map { |s| a = s.to_a; a.first..a.last }
      end

      def matched_characters
        regexp.respond_to?(:match?) ||
          regexp.define_singleton_method(:match?) { |str| !!match(str) }

        @@characters ||= ((0..0xD7FF).to_a + (0xE000..0x10FFFF).to_a)
                         .map { |cp_number| [cp_number].pack('U') }

        @@characters.select { |char| regexp.match?(char) }
      end

      def character_set
        require 'character_set'
        CharacterSet.new(matched_codepoints)
      end
    end
  end
end

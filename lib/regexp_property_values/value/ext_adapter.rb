module RegexpPropertyValues
  class Value
    module ExtAdapter
      def matched_characters
        acc = []
        matched_codepoints.each do |cp|
          acc << cp.chr('utf-8') if cp < 0xD800 || cp > 0xDFFF
        end
        acc
      end

      def matched_codepoints
        OnigRegexpPropertyHelper.matched_codepoints(name)
      rescue ArgumentError
        raise_unsupported_or_unknown_error
      end

      def matched_ranges
        OnigRegexpPropertyHelper.matched_ranges(name)
      rescue ArgumentError
        raise_unsupported_or_unknown_error
      end
    end
  end
end

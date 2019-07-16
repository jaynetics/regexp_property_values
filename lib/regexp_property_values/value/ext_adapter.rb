module RegexpPropertyValues
  class Value
    module ExtAdapter
      def matched_characters
        matched_codepoints.map { |cp| cp.chr('utf-8') }
      end

      def matched_codepoints
        matched_ranges.flat_map(&:to_a)
      end

      def matched_ranges
        OnigRegexpPropertyHelper.matched_ranges(name)
      rescue ArgumentError
        raise_unsupported_or_unknown_error
      end
    end
  end
end

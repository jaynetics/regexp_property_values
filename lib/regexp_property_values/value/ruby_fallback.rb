module RegexpPropertyValues
  class Value
    module RubyFallback
      def matched_characters
        matched_codepoints.map { |cp| cp.chr('utf-8') }
      end

      def matched_codepoints
        # turns out scanning one big string is the least slow way to do this
        @@test_str ||= (0..0xD7FF).map { |cp| cp.chr('utf-8') }.join <<
                       (0xE000..0x10FFFF).map { |cp| cp.chr('utf-8') }.join
        @@test_str.scan(regexp).flat_map(&:codepoints)
      end

      def matched_ranges
        require 'range_compressor'
        RangeCompressor.compress(matched_codepoints)
      end
    end
  end
end

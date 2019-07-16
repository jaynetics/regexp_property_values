module RegexpPropertyValues
  class Value
    module SharedMethods
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def supported_by_current_ruby?
        !!regexp rescue false
      end

      def ==(other)
        identifier == other.identifier
      end
      alias eql? ==

      def hash
        @hash ||= identifier.hash
      end

      def identifier
        @identifier ||= name.to_s.downcase.gsub(/[^0-9a-z=.]/, '')
      end
      alias to_s identifier

      def full_name
        (original = find_original) ? original.name : raise_unknown_error
      end

      def character_set
        require 'character_set'
        CharacterSet.from_ranges(*matched_ranges)
      end

      private

      def regexp
        @regexp ||= /\p{#{identifier}}/u
      rescue RegexpError, SyntaxError
        raise_unsupported_or_unknown_error
      end

      def find_original
        RegexpPropertyValues.all.find { |orig| orig.eql?(self) } ||
          RegexpPropertyValues.alias_hash[self]
      end

      def raise_unsupported_or_unknown_error
        find_original ? raise_unsupported_error : raise_unknown_error
      end

      def raise_unsupported_error
        raise Error, "Property name `#{name}` is known, but not in this Ruby"
      end

      def raise_unknown_error
        raise Error, "Property name `#{name}` is not known in any Ruby"
      end
    end
  end
end

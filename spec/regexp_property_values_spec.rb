RSpec.describe RegexpPropertyValues do
  Value = described_class::Value

  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '::all' do
    it 'returns an array of property values' do
      result = described_class.all
      expect(result).to include(Value.new('ASCII'))
      expect(result).to include(Value.new('Letter'))
    end

    it 'includes derived and general categories, ages, scripts, etc.' do
      result = described_class.all
      expect(result).to include(Value.new('Age=2.0'))
      expect(result).to include(Value.new('Arabic'))
      expect(result).to include(Value.new('Cased'))
      expect(result).to include(Value.new('Currency_Symbol'))
      expect(result).to include(Value.new('Math'))
    end

    it 'includes recently added properties irrespective of Ruby version' do
      result = described_class.all
      expect(result).to include(Value.new('Age=6.1'))
      expect(result).to include(Value.new('Chakma'))
      expect(result).to include(Value.new('In_Arabic'))
    end

    it 'includes the dropped `Newline` property irrespective of Ruby version' do
      expect(described_class.all).to include(Value.new('Newline'))
    end
  end

  describe '::all_for_current_ruby' do
    it 'returns an array of property names' do
      result = described_class.all_for_current_ruby
      expect(result).to include(Value.new('Alpha'))
      expect(result).to include(Value.new('Space'))
    end

    if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.0.0')
      it 'includes recently added properties' do
        result = described_class.all_for_current_ruby
        expect(result).to include(Value.new('Age=6.1'))
        expect(result).to include(Value.new('Chakma'))
      end

      if RUBY_PLATFORM !~ /java/i
        it 'does not include the dropped `Newline` property' do
          result = described_class.all_for_current_ruby
          expect(result).not_to include(Value.new('Newline'))
        end
      end
    else # ruby 1.9.3 and below - Oniguruma regex engine
      it 'does not include recently added properties' do
        result = described_class.all_for_current_ruby
        expect(result).not_to include(Value.new('Age=6.1'))
        expect(result).not_to include(Value.new('Chakma'))
      end

      it 'includes the dropped `Newline` property' do
        result = described_class.all_for_current_ruby
        expect(result).to include(Value.new('Newline'))
      end
    end
  end

  describe '::alias_hash' do
    it 'returns a Hash of aliases mapped to their long variants' do
      result = described_class.alias_hash
      expect(result[Value.new('grek')]).to eq Value.new('greek')
      expect(result[Value.new('Ll')]).to   eq Value.new('Lowercase letter')
      expect(result[Value.new('M')]).to    eq Value.new('Mark')
    end
  end
end

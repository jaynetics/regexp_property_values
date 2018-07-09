RSpec.describe RegexpPropertyValues do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '::all' do
    it 'returns an array of property names' do
      result = described_class.all
      expect(result).to include('Alpha')
      expect(result).to include('Space')
    end

    it 'includes short names and long names' do
      result = described_class.all
      expect(result).to include('M')
      expect(result).to include('Nl')
      expect(result).to include('Mark')
      expect(result).to include('Letter_Number')
    end

    it 'includes derived and general categories, ages, scripts, etc.' do
      result = described_class.all
      expect(result).to include('Age=2.0')
      expect(result).to include('AHex')
      expect(result).to include('Arabic')
      expect(result).to include('Cased')
      expect(result).to include('Currency_Symbol')
      expect(result).to include('Math')
    end

    it 'includes recently added properties irrespective of Ruby version' do
      result = described_class.all
      expect(result).to include('Age=6.1')
      expect(result).to include('Chakma')
      expect(result).to include('In_Arabic')
    end

    it 'includes the dropped `Newline` property irrespective of Ruby version' do
      expect(described_class.all).to include('Newline')
    end
  end

  describe '::all_for_current_ruby' do
    it 'returns an array of property names' do
      result = described_class.all_for_current_ruby
      expect(result).to include('Alpha')
      expect(result).to include('Space')
    end

    if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.0.0')
      it 'includes recently added properties' do
        result = described_class.all_for_current_ruby
        expect(result).to include('Age=6.1')
        expect(result).to include('Chakma')
      end

      if RUBY_PLATFORM !~ /java/i
        it 'does not include the dropped `Newline` property' do
          expect(described_class.all_for_current_ruby).not_to include('Newline')
        end
      end
    else # ruby 1.9.3 and below - Oniguruma regex engine
      it 'does not include recently added properties' do
        result = described_class.all_for_current_ruby
        expect(result).not_to include('Age=6.1')
        expect(result).not_to include('Chakma')
      end

      it 'includes the dropped `Newline` property' do
        expect(described_class.all_for_current_ruby).to include('Newline')
      end
    end
  end

  describe '::by_category' do
    it 'lists properties by category' do
      result = described_class.by_category
      expect(result.keys.sort).to eq([
        'Blocks',
        'DerivedAges',
        'DerivedCoreProperties',
        'Emoji',
        'Major and General Categories',
        'POSIX brackets',
        'PropList',
        'PropertyAliases',
        'PropertyValueAliases (General_Category)',
        'PropertyValueAliases (Script)',
        'Scripts',
        'Special'
      ])
      expect(result['DerivedAges']).to include('Age=2.0')
      expect(result['POSIX brackets']).to include('Space')
    end
  end

  describe '::short_and_long_names' do
    it 'returns distinct arrays of short and long property aliases' do
      short, long = described_class.short_and_long_names
      expect(short & long).to be_empty
      expect(short).to include('M')
      expect(short).to include('Grek')
      expect(short).to include('Zs')
      expect(long).to include('Mark')
      expect(long).to include('Greek')
      expect(long).to include('Space')
    end
  end

  describe '::alias_hash' do
    before { allow(described_class).to receive(:puts) } # silence

    it 'returns a hash of all short aliases mapping to their long variants' do
      allow(described_class).to receive(:all).and_return(
        %w[AHex Grek Greek].map { |e| described_class[e] }
      )
      expect(described_class.alias_hash).to eq('Grek' => 'Greek')
    end

    it 'maps short aliases to non-posix long names' do
      allow(described_class).to receive(:all).and_return(
        %w[Cntrl Cc Cntrl Control Cntrl].map { |e| described_class[e] }
      )
      expect(described_class.alias_hash).to eq('Cc' => 'Control')
    end
  end
end

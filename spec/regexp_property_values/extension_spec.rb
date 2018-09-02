RSpec.describe RegexpPropertyValues::Extension do
  Extension = described_class

  describe '#matched_characters' do
    it 'returns all characters matched by the property' do
      expect('AHex'.extend(Extension).matched_characters).to eq(
        %w[0 1 2 3 4 5 6 7 8 9 A B C D E F a b c d e f]
      )
    end

    it 'does not crash or segfault for non-utf-8 encodings' do
      expect('AHex'.encode('ascii').extend(Extension).matched_characters)
        .not_to be_empty
    end
  end

  describe '#matched_codepoints' do
    it 'returns all codepoints matched by the property' do
      expect('AHex'.extend(Extension).matched_codepoints).to eq(
        [48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
         65, 66, 67, 68, 69, 70,
         97, 98, 99, 100, 101, 102]
      )
    end
  end

  describe '#matched_ranges' do
    it 'returns all codepoint ranges matched by the property' do
      expect('AHex'.extend(Extension).matched_ranges).to eq(
        [48..57, 65..70, 97..102]
      )
    end
  end

  describe '#character_set' do
    it 'returns a CharacterSet with the correct codepoints' do
      require 'character_set'

      expect('AHex'.extend(Extension).character_set).to eq(
        CharacterSet.from_ranges(48..57, 65..70, 97..102)
      )
    end
  end

  describe '#supported_by_current_ruby?' do
    it 'returns true iff the property is supported' do
      expect('foo'.extend(Extension).supported_by_current_ruby?).to be false
      expect('word'.extend(Extension).supported_by_current_ruby?).to be true
    end
  end
end

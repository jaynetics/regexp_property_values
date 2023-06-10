module RegexpPropertyValues
  module Updater
    module_function

    require 'fileutils'
    require 'set'

    BASE_URL = 'https://www.unicode.org/Public/UCD/latest/ucd'

    UCD_FILES = %w[
      Blocks.txt
      DerivedAge.txt
      DerivedCoreProperties.txt
      PropertyAliases.txt
      PropertyValueAliases.txt
      PropList.txt
      Scripts.txt
    ]

    EMOJI_FILES = %w[
      emoji-data.txt
    ]

    TMP_DIR = File.join(__dir__, 'tmp_ucd')

    def call(ucd_path: nil, emoji_path: nil)
      prepare_tmp_dir
      download_ucd_files(ucd_path: ucd_path, emoji_path: emoji_path)
      write_values
      write_aliases
      remove_tmp_dir
      print_stats
    end

    def prepare_tmp_dir
      FileUtils.rm_rf(TMP_DIR) if File.exist?(TMP_DIR)
      FileUtils.mkdir(TMP_DIR)
    end

    def download_ucd_files(ucd_path: nil, emoji_path: nil)
      puts 'This will try to load the latest UCD data. Continue? [y/n]'
      return puts 'download skipped.' unless $stdin.gets =~ /^y/i

      ucd_path   ||= ENV['RPV_UCD_PATH']   || BASE_URL
      emoji_path ||= ENV['RPV_EMOJI_PATH'] || "#{BASE_URL}/emoji/"

      Dir.chdir(TMP_DIR) do
        UCD_FILES.each   { |f| `wget #{ucd_path}/#{f}` }
        EMOJI_FILES.each { |f| `wget #{emoji_path}/#{f}` }
      end
    end

    def write_values
      @values = Set.new

      # posix properties
      @values += %w[
        Alpha Blank Cntrl Digit Graph Lower Print
        Punct Space Upper XDigit Word Alnum ASCII
        XPosixPunct
      ]

      # special properties
      @values += %w[
        Any Assigned Extended_Pictographic In_No_Block Unknown
      ]

      # legacy properties
      @values += %w[Newline]

      regexp = /^[0-9a-fA-F]+(?:\.\.[0-9a-fA-F]+)? *; (?<prop_name>\w+) +# /
      %w[
        DerivedCoreProperties.txt
        PropList.txt
        Scripts.txt
        emoji-data.txt
      ].each { |file| scan(file, regexp) { |caps| @values << caps[:prop_name] } }

      scan('PropertyValueAliases.txt', /^gc ; \w+ *; (?<prop_name>\w+)/) do |caps|
        @values << caps[:prop_name]
      end

      scan('Blocks.txt', /^[\dA-F.]+ *; (?<block_name>[-\w ]+)/) do |caps|
        @values << 'In_' + caps[:block_name].gsub(/\W/, '_')
      end

      scan('DerivedAge.txt', /^[\dA-F.]+ *; (?<age_num>[\d.]+)/) do |caps|
        @values << 'Age=' + caps[:age_num]
      end

      File.write(RegexpPropertyValues::VALUES_PATH, @values.sort.join("\n"))
    end

    def write_aliases
      @aliases = Set.new

      scan('PropertyAliases.txt', /^(?<alias>\w+) *; (?<name>\w+)/) do |caps|
        if in_values?(caps[:name]) && !in_values?(caps[:alias])
          @aliases << [caps[:alias], caps[:name]]
        end
      end

      scan('PropertyValueAliases.txt',
        /^[gs]c ; (?<alias1>\w+) *; (?<name>\w+)(?: *; (?<alias2>\w+))?/) do |caps|
        if in_values?(caps[:name]) && !in_values?(caps[:alias1])
          @aliases << [caps[:alias1], caps[:name]]
        end
        if in_values?(caps[:name]) && caps[:alias2] && !in_values?(caps[:alias2])
          @aliases << [caps[:alias2], caps[:name]]
        end
      end

      File.write(RegexpPropertyValues::ALIASES_PATH,
                 @aliases.sort.map { |pair| pair.join(';') }.join("\n"))
    end

    def in_values?(string)
      @values.any? { |value| value.casecmp?(string) }
    end

    def scan(file, pattern)
      path = File.join(TMP_DIR, file)
      File.read(path).scan(pattern) { yield(Regexp.last_match) }
    end

    def remove_tmp_dir
      FileUtils.rm_rf(TMP_DIR)
    end

    def print_stats
      print "\nFetched #{@values.size} values and #{@aliases.size} aliases.\n\n"
    end
  end
end

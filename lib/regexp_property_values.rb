begin
  require 'regexp_property_values/regexp_property_values'
rescue LoadError
  warn 'regexp_property_values could not load C extension, using slower Ruby'
end
require 'regexp_property_values/updater'
require 'regexp_property_values/value'
require 'regexp_property_values/version'

module RegexpPropertyValues
  Error = Class.new(StandardError)

  VALUES_PATH  = File.join(__dir__, 'values')
  ALIASES_PATH = File.join(__dir__, 'aliases')

  def self.[](name)
    Value.new(name)
  end

  def self.all_for_current_ruby
    @all_for_current_ruby ||= all.select(&:supported_by_current_ruby?)
  end

  def self.all
    @all ||= File.readlines(VALUES_PATH).map { |line| Value.new(line.chomp) }
  end

  def self.alias_hash
    @alias_hash ||= File.readlines(ALIASES_PATH).map do |line|
      line.chomp.split(';').map { |name| Value.new(name) }
    end.to_h
  end

  def self.update(ucd_path: nil, emoji_path: nil)
    Updater.call(ucd_path: ucd_path, emoji_path: emoji_path)
  end
end

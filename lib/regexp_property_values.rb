require 'regexp_property_values/value_extension'
require 'regexp_property_values/version'

module RegexpPropertyValues
  module_function

  LIST_URL = 'https://raw.githubusercontent.com/k-takata/Onigmo/master/doc/UnicodeProps.txt'

  def update
    puts "Downloading #{LIST_URL}"
    require 'open-uri'
    File.open(file_path, 'w') { |f| IO.copy_stream(open(LIST_URL), f) }
    puts 'Done!'
  end

  def file_path
    File.expand_path('../UnicodeProps.txt', __FILE__)
  end

  def all
    by_category.values.flatten
  end

  def all_for_current_ruby
    all.select(&:supported_by_current_ruby?)
  end

  def by_category
    result = File.foreach(file_path).inject({}) do |hash, line|
      if /^\* (?<category>\S.+)/ =~ line
        @current_category = category
        hash[@current_category] ||= []
      elsif /^ {4}(?<value_name>\S.*)/ =~ line
        hash[@current_category] << value(value_name)
      end
      hash
    end
    add_oniguruma_properties(result)
    result
  end

  def add_oniguruma_properties(props_by_category)
    props_by_category['Special'] << value('Newline')
  end

  def alias_hash
    short_names, long_names = short_and_long_names
    return {} if short_names.empty?

    long_names -= by_category['POSIX brackets']
    by_matched_characters.each_value.inject({}) do |hash, props|
      next hash if props.count < 2
      long_name = (props & long_names)[0] || fail("no long name for #{props}")
      (props & short_names).each { |short_name| hash[short_name] = long_name }
      hash
    end
  end

  def short_and_long_names
    short_name_categories = ['Major and General Categories',
                             'PropertyAliases',
                             'PropertyValueAliases (Script)']
    by_category.inject([[], []]) do |(short, long), (cat_name, props)|
      (short_name_categories.include?(cat_name) ? short : long).concat(props)
      [short, long]
    end
  end

  def by_matched_characters
    puts 'Establishing property characters, this may take a bit ...'
    all.group_by(&:matched_characters)
  end

  def matched_characters(prop)
    value(prop).matched_characters
  end

  def supported_by_current_ruby?(prop)
    value(prop).supported_by_current_ruby?
  end

  def value(prop)
    prop.singleton_class.send(:include, ValueExtension)
    prop
  end
end

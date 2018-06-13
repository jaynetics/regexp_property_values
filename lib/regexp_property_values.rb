begin
  require 'regexp_property_values/regexp_property_values'
rescue LoadError
  warn 'regexp_property_values could not load C extension, using slower Ruby'
end
require 'regexp_property_values/extension'
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
    result = File.foreach(file_path).each_with_object({}) do |line, hash|
      if /^\* (?<category>\S.+)/ =~ line
        @current_category = category
        hash[@current_category] ||= []
      elsif /^ {4}(?<value_name>\S.*)/ =~ line
        hash[@current_category] << value_name.extend(Extension)
      end
    end
    add_oniguruma_properties(result)
    result
  end

  def add_oniguruma_properties(props_by_category)
    props_by_category['Special'] << 'Newline'.extend(Extension)
  end

  def alias_hash
    short_names, long_names = short_and_long_names
    return {} if short_names.empty?

    long_names -= by_category['POSIX brackets']
    by_matched_codepoints.each_value.each_with_object({}) do |props, hash|
      next if props.count < 2
      long_name = (props & long_names)[0] || fail("no long name for #{props}")
      (props & short_names).each { |short_name| hash[short_name] = long_name }
    end
  end

  def short_and_long_names
    short_name_categories = ['Major and General Categories',
                             'PropertyAliases',
                             'PropertyValueAliases (Script)']
    by_category.each_with_object([[], []]) do |(cat_name, props), (short, long)|
      (short_name_categories.include?(cat_name) ? short : long).concat(props)
    end
  end

  def by_matched_codepoints
    puts 'Establishing property codepoints, this may take a bit ...'
    all_for_current_ruby.group_by(&:matched_codepoints)
  end

  def [](prop)
    prop.extend(Extension)
  end
end

require "regexp_property_values/version"

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

  def by_category
    result = File.foreach(file_path).inject({}) do |hash, line|
      if /^\* (?<category>\S.+)/ =~ line
        @current_category = category
        hash[@current_category] ||= []
      elsif /^ {4}(?<property>\S.*)/ =~ line
        # only include props that are supported by the host ruby version
        begin /\p{#{property}}/u; rescue RegexpError, SyntaxError; next hash end
        hash[@current_category] << property
      end
      hash
    end
    add_oniguruma_properties(result)
    result
  end

  def alias_hash
    short_names, long_names = short_and_long_names
    return {} if short_names.empty?

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
    all.group_by { |prop| matched_characters(prop) }
  end

  def matched_characters(prop)
    @characters ||= ((0..55_295).to_a + (57_344..1_114_111).to_a)
                    .map { |cp_number| [cp_number].pack('U') }
    prop_regex = /\p{#{prop}}/u
    @characters.select { |char| prop_regex.match(char) }
  end

  def add_oniguruma_properties(props_by_category)
    return if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.0.0')
    props_by_category['Special'] << 'Newline'
  end
end

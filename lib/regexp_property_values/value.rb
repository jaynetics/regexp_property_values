module RegexpPropertyValues
  class Value
    require_relative 'value/shared_methods'
    include SharedMethods

    if const_defined?(:OnigRegexpPropertyHelper)
      require_relative 'value/ext_adapter'
      include ExtAdapter
    else
      require_relative 'value/ruby_fallback'
      include RubyFallback
    end
  end
end

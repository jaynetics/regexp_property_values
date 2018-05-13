# RegexpPropertyValues

[![Gem Version](https://badge.fury.io/rb/regexp_property_values.svg)](http://badge.fury.io/rb/regexp_property_values)
[![Build Status](https://travis-ci.org/janosch-x/regexp_property_values.svg?branch=master)](https://travis-ci.org/janosch-x/regexp_property_values)

This microlibrary lets you see which property values are supported by the regular expression engine of the Ruby version you are running.

That is, it determines all supported values for `\p{value}` expressions.

## Usage

##### Browse all property values (supported by any Ruby, ever)

```ruby
require 'regexp_property_values'

PV = RegexpPropertyValues

PV.all # => ["Alpha", "Blank", "Cntrl", ...]
PV.all.sort # => ["AHex", "ASCII", "Adlam", "Adlm", "Age=1.1", ...]

PV.by_category # => {"POSIX brackets" => ["Alpha", ...], "Special" => ...}

PV.short_and_long_names # => [["M", "Grek", ...], ["Mark", "Greek", ...]]
```

##### Browse property values supported by the Ruby you are running

```ruby
PV.all_for_current_ruby # => ["Alpha", "Blank", "Cntrl", ...]
PV.all_for_current_ruby.include?('Newline') # => false

PV.by_category.map { |k, v| [k, v.select(&:supported_by_current_ruby?] }

PV.short_and_long_names.map { |a| a.select(&:supported_by_current_ruby?) }
```

##### Utility methods

```ruby
PV.supported_by_current_ruby?('alpha') # => true
PV.supported_by_current_ruby?('foobar') # => false

# this one takes a second
PV.matched_characters('AHex') # => %w[0 1 2 3 4 5 6 7 8 9 A B C ...]

# this one takes a minute or two
PV.alias_hash # => {"M" => "Mark", "Grek" => "Greek", ...}

# download the latest list of possible properties
PV.update
```

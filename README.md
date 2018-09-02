# RegexpPropertyValues

[![Gem Version](https://badge.fury.io/rb/regexp_property_values.svg)](http://badge.fury.io/rb/regexp_property_values)
[![Build Status](https://travis-ci.org/janosch-x/regexp_property_values.svg?branch=master)](https://travis-ci.org/janosch-x/regexp_property_values)

This small library lets you see which property values are supported by the regular expression engine of the Ruby version you are running and directly reads out their codepoint ranges from there.

That is, it determines all supported values for `\p{value}` expressions and what they match.

## Usage

##### Browse all property values (supported by any Ruby, ever)

```ruby
require 'regexp_property_values'

PV = RegexpPropertyValues

PV.all # => ["Alpha", "Blank", "Cntrl", ...]
PV.by_category # => {"POSIX brackets" => ["Alpha", ...], "Special" => ...}
PV.short_and_long_names # => [["M", "Grek", ...], ["Mark", "Greek", ...]]
```

##### Browse property values supported by the Ruby you are running

```ruby
PV.all_for_current_ruby # => ["Alpha", "Blank", "Cntrl", ...]

PV.by_category.map { |k, v| [k, v.select(&:supported_by_current_ruby?] }

# etc.
```

##### Inspect properties

```ruby
PV['alpha'].supported_by_current_ruby? # => true
PV['foobar'].supported_by_current_ruby? # => false

PV['AHex'].matched_characters # => %w[0 1 2 3 4 5 6 7 8 9 A B C ...]
PV['AHex'].matched_codepoints # => [48, 49, 50, ...]
PV['AHex'].matched_ranges # => [48..57, 65..70, 97..102]
```

If [`character_set`](https://github.com/janosch-x/character_set) is installed, you can also do this:

```ruby
PV['AHex'].character_set # => #<CharacterSet: {48, 49...} (size: 22)>
```

##### Utility methods

```ruby
# This one takes a few seconds (or minutes, without the C extension)
PV.alias_hash # => {"M" => "Mark", "Grek" => "Greek", ...}

# download the latest list of possible properties
PV.update
```

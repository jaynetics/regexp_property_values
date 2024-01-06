# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2024-01-06

### Added
- new properties of future Ruby 3.3.x / Unicode 15.1

## [1.4.0] - 2023-06-10

### Added
- new properties of Ruby 3.2 / Unicode 15.0

## [1.3.0] - 2022-04-07

### Added
- new properties of Ruby 3.2 / Unicode 14.0

## [1.2.0] - 2021-12-31

### Added
- support for usage in Ractors

## [1.1.0] - 2021-12-05

### Added
- added new properties from Ruby `3.1.0` to output of `::all`, `::all_for_current_ruby`
- added options to run `::update` with custom ucd/emoji source paths

## [1.0.0] - 2019-06-16

### Changed
- removed `::by_category`, `::by_matched_codepoints`, `::short_and_long_names`
- return values are now always of a custom `Value` class, no longer extended `Strings`
- unknown properties now raise `RegexpPropertyValues::Error`, no longer an `ArgumentError`

### Added
- `Value#identifier`
- `Value#full_name`

### Fixed
- better codepoint determination speed for non-C Rubies (still slow)

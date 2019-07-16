# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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

# Changelog

Notable changes to this project will be documented in this file.

## [1.2.0](https://github.com/mvz/non-digest-assets/tree/v1.2.0)

### Summary

- Drop support for Ruby 2.4 and Rails 5.1 and lower
- Deprecate `whitelist` setting in favor of `asset_selectors`
- Do not clobber files if logical path and digest path are the same

### Fixed bugs

- Release 1.1.0 breaks the asset compilation [\#34](https://github.com/mvz/non-digest-assets/issues/34)

### Merged pull requests

- Copy files more carefully [\#45](https://github.com/mvz/non-digest-assets/pull/45) ([mvz](https://github.com/mvz))
- Deprecate whitelist in favor of new asset\_selectors accessor [\#44](https://github.com/mvz/non-digest-assets/pull/44) ([mvz](https://github.com/mvz))
- Drop support for Ruby 2.4 [\#30](https://github.com/mvz/non-digest-assets/pull/30) ([mvz](https://github.com/mvz))
- Drop support for Rails 5.1 and below [\#29](https://github.com/mvz/non-digest-assets/pull/29) ([mvz](https://github.com/mvz))

[Full Changelog](https://github.com/mvz/non-digest-assets/compare/v1.1.0...v1.2.0)

## [1.1.0](https://github.com/mvz/non-digest-assets/tree/v1.1.0) (2020-05-01)

### Summary

- Preserve atime and mtime attributes even if asset creation is run by different users
- Add tests
- Officially support Rails 6.0 and 6.1, and Ruby 3.0

### Merged pull requests

- Run tests on Ruby 3.0 with Rails 6+ in CI [\#19](https://github.com/mvz/non-digest-assets/pull/19) ([mvz](https://github.com/mvz))
- Add Appraisal for Rails 6.1 [\#18](https://github.com/mvz/non-digest-assets/pull/18) ([mvz](https://github.com/mvz))
- Improve test setup [\#8](https://github.com/mvz/non-digest-assets/pull/8) ([mvz](https://github.com/mvz))
- Remove file first so utime doesn't fail for other users. [\#2](https://github.com/mvz/non-digest-assets/pull/2) ([zbelzer](https://github.com/zbelzer))

[Full Changelog](https://github.com/mvz/non-digest-assets/compare/v1.0.10...v1.1.0)

## [1.0.10](https://github.com/mvz/non-digest-assets/tree/v1.0.10) (2018-06-16)

**Initial release**

- Fork from non-stupid-digest-assets
- Make gem name, code and documentation less angry

[Full Changelog](https://github.com/mvz/non-digest-assets/compare/cb899cc4...v1.0.10)


## [2026-02-07] Task 8: RuboCop config updated
- Removed rubocop-rspec and rubocop-rspec_rails plugins
- Removed all RSpec/* configuration sections (MultipleExpectations, ExampleLength, NestedGroups, MultipleMemoizedHelpers, ContextWording, AnyInstance)
- Updated Metrics excludes: spec/**/* → test/**/*
- Kept rubocop-capybara and rubocop-factory_bot (work with Minitest)
- RuboCop loads successfully without RSpec plugins (v1.79.2)
- Config now has 53 lines (down from 74)

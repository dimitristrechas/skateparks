# RSpec to Minitest Migration

## TL;DR

> **Quick Summary**: Complete migration from RSpec to Minitest with classic syntax, removing all RSpec gems to reduce complexity and test execution time.
>
> **Deliverables**:
>
> - All test files converted: spec/**/\*\_spec.rb → test/**/\*\_test.rb
> - Test helpers migrated to Minitest
> - RSpec gems removed from Gemfile
> - RuboCop config updated (remove RSpec plugins)
> - Docker test setup updated
> - Native Ruby coverage enabled
>
> **Estimated Effort**: Medium
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 1 → Task 4 → Task 5 → Task 6

---

## Context

### Original Request

Migrate from RSpec to Minitest to reduce test execution time, simplify test code, and remove all RSpec-related gems.

### Interview Summary

**Key Discussions**:

- Syntax choice: Classic Minitest (test* methods, assert*\*)
- Migration approach: All at once (20 test files)
- Coverage tool: Native Ruby coverage (remove SimpleCov)
- ViewComponent: Minitest ViewComponent integration
- Docker-based test execution must continue working

**Current Test Setup**:

- RSpec 8.0 with rspec-rails gem
- FactoryBot for fixtures (keeping)
- Capybara for system tests (keeping)
- SimpleCov for coverage (removing)
- 20 test files: models, controllers, components, system, jobs, helpers, mailers, channels
- Docker compose test environment required

---

## Work Objectives

### Core Objective

Migrate all tests from RSpec to Minitest using classic syntax while maintaining test coverage and Docker-based execution workflow.

### Concrete Deliverables

- test/ directory with all migrated test files
- test/test_helper.rb (Minitest configuration)
- Gemfile without RSpec gems
- .rubocop.yml without RSpec plugins
- Updated Docker test commands in scripts.sh
- Native coverage setup in test_helper.rb

### Definition of Done

- [x] All 20 spec files converted to test files
- [x] `docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test` runs successfully
- [x] All existing test scenarios pass
- [x] RuboCop passes with updated config
- [x] Coverage reporting works with native Ruby coverage

### Must Have

- Classic Minitest syntax (test\_ methods, assert_equal, refute, etc.)
- FactoryBot integration maintained
- Capybara system tests functional
- All existing test coverage preserved
- Docker test execution working

### Must NOT Have (Guardrails)

- Minitest::Spec DSL (describe/it blocks)
- SimpleCov gem
- Any RSpec gems remaining
- rubocop-rspec or rubocop-rspec_rails plugins
- Changes to test data/factories (migration only)
- New test coverage additions (migrate existing only)
- CI/CD changes (focus on local Docker setup)

---

## Verification Strategy

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.

### Test Decision

- **Infrastructure exists**: YES (RSpec, migrating to Minitest)
- **Automated tests**: Tests-after (verify migration worked)
- **Framework**: Minitest (Rails built-in)

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

> ALL verification executed by agent using Docker commands and file checks.
> No manual testing or human confirmation required.

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: Create Minitest test_helper.rb with configuration
└── Task 2: Remove RSpec gems from Gemfile

Wave 2 (After Wave 1):
├── Task 3: Convert model tests (1 file)
├── Task 4: Convert controller tests (4 files)
├── Task 5: Convert component tests (8 files)
├── Task 6: Convert system/integration tests (if exist)
└── Task 7: Convert job/worker/helper/mailer tests (7 files)

Wave 3 (After Wave 2):
├── Task 8: Update RuboCop config (remove RSpec plugins)
├── Task 9: Update Docker test commands in scripts.sh
└── Task 10: Remove spec/ directory and RSpec config files

Critical Path: Task 1 → Task 3 → Task 10
Parallel Speedup: ~50% faster (Wave 2 tasks run concurrently)
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
| ---- | ---------- | ------ | -------------------- |
| 1    | None       | 3-7    | 2                    |
| 2    | None       | 10     | 1                    |
| 3    | 1          | 10     | 4, 5, 6, 7           |
| 4    | 1          | 10     | 3, 5, 6, 7           |
| 5    | 1          | 10     | 3, 4, 6, 7           |
| 6    | 1          | 10     | 3, 4, 5, 7           |
| 7    | 1          | 10     | 3, 4, 5, 6           |
| 8    | 2          | None   | 9                    |
| 9    | 3-7        | None   | 8                    |
| 10   | 2-9        | None   | None (cleanup)       |

---

## TODOs

- [x] 1. Create Minitest test_helper.rb with configuration

  **What to do**:
  - Create test/test_helper.rb with ENV setup, Rails load, Minitest configuration
  - Configure FactoryBot for Minitest (include FactoryBot::Syntax::Methods)
  - Set up native Ruby coverage (Coverage.start with :all mode)
  - Configure transactional fixtures
  - Set up Capybara for system tests
  - Include necessary test helpers (ActionView::Helpers::SanitizeHelper, route helpers)

  **Must NOT do**:
  - Use SimpleCov (removed, use native coverage)
  - Include RSpec configuration
  - Use Minitest::Spec DSL setup

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Straightforward file creation following Rails conventions
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: No specialized domain knowledge needed for test helper setup

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: Tasks 3, 4, 5, 6, 7 (all test conversions need this helper)
  - **Blocked By**: None (can start immediately)

  **References**:
  - `spec/rails_helper.rb:1-73` - Current RSpec Rails setup (use as reference for needed config)
  - `spec/spec_helper.rb:1-97` - RSpec configuration (translate relevant settings)
  - `spec/support/factory_bot.rb:1-6` - FactoryBot RSpec integration (adapt for Minitest)
  - `spec/support/simplecov.rb:1-16` - SimpleCov config (replace with native coverage)
  - Rails docs: https://guides.rubyonrails.org/testing.html#the-test-environment - Minitest setup guide
  - FactoryBot docs: https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#minitest - Minitest integration

  **WHY Each Reference Matters**:
  - rails_helper.rb: Shows fixture paths, transactional fixtures, default_url_options needed
  - spec_helper.rb: Shows randomization, profile settings to translate
  - factory_bot.rb: Pattern for FactoryBot integration (change RSpec to ActiveSupport::TestCase)
  - simplecov.rb: Coverage groups to replicate with native Coverage module

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: test_helper loads and configures Rails test environment
    Tool: Bash (ruby command)
    Preconditions: test/test_helper.rb created
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test ruby -Itest -e "require './test/test_helper'; puts 'OK'"
      2. Assert: stdout contains "OK"
      3. Assert: exit code 0
    Expected Result: Helper loads without errors
    Failure Indicators: LoadError, NameError, exit code != 0
    Evidence: Command output captured

  Scenario: FactoryBot methods available in test context
    Tool: Bash (ruby test)
    Preconditions: test_helper loaded
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test ruby -Itest -e "require './test/test_helper'; include FactoryBot::Syntax::Methods; puts build(:skatepark).class"
      2. Assert: stdout contains "Skatepark"
      3. Assert: exit code 0
    Expected Result: FactoryBot methods work
    Evidence: Command output

  Scenario: Native coverage starts successfully
    Tool: Bash (grep coverage config)
    Preconditions: test_helper contains Coverage.start
    Steps:
      1. grep -q "Coverage.start" test/test_helper.rb
      2. Assert: exit code 0 (pattern found)
    Expected Result: Coverage configured
    Evidence: grep exit code
  ```

  **Evidence to Capture**:
  - [ ] Command outputs in .sisyphus/evidence/task-1-helper-load.txt
  - [ ] Factory bot test output in .sisyphus/evidence/task-1-factorybot.txt

  **Commit**: NO (groups with 2)

---

- [x] 2. Remove RSpec gems from Gemfile

  **What to do**:
  - Remove rspec-rails from development/test group
  - Remove rubocop-rspec from development group
  - Remove rubocop-rspec_rails from development group
  - Remove simplecov from test group
  - Keep: factory_bot_rails, capybara, faker, rails-controller-testing
  - Run bundle install

  **Must NOT do**:
  - Remove FactoryBot, Capybara, Faker (needed for Minitest)
  - Remove rails-controller-testing (needed for controller tests)
  - Touch Gemfile.lock manually (bundle handles it)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Simple gem removal and bundle update
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Straightforward dependency management

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: Task 10 (can't remove spec/ until gems gone)
  - **Blocked By**: None (can start immediately)

  **References**:
  - `Gemfile:44-86` - Current gem configuration
  - `Gemfile:50` - rspec-rails gem line to remove
  - `Gemfile:73-74` - rubocop-rspec gems to remove
  - `Gemfile:85` - simplecov gem to remove

  **WHY Each Reference Matters**:
  - Gemfile shows exact lines to remove and gems to preserve
  - Test group gems (factory_bot_rails, capybara, faker) must remain

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: RSpec gems removed from Gemfile
    Tool: Bash (grep)
    Preconditions: Gemfile edited
    Steps:
      1. grep -q "rspec-rails" Gemfile && echo "FOUND" || echo "NOTFOUND"
      2. Assert: stdout contains "NOTFOUND"
      3. grep -q "rubocop-rspec" Gemfile && echo "FOUND" || echo "NOTFOUND"
      4. Assert: stdout contains "NOTFOUND"
      5. grep -q "simplecov" Gemfile && echo "FOUND" || echo "NOTFOUND"
      6. Assert: stdout contains "NOTFOUND"
    Expected Result: RSpec gems absent
    Evidence: grep outputs

  Scenario: Required test gems still present
    Tool: Bash (grep)
    Preconditions: Gemfile edited
    Steps:
      1. grep -q "factory_bot_rails" Gemfile
      2. Assert: exit code 0 (found)
      3. grep -q "capybara" Gemfile
      4. Assert: exit code 0
      5. grep -q "faker" Gemfile
      6. Assert: exit code 0
    Expected Result: FactoryBot, Capybara, Faker remain
    Evidence: grep exit codes

  Scenario: Bundle install succeeds
    Tool: Bash (docker bundle)
    Preconditions: Gemfile updated
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bundle install
      2. Assert: exit code 0
      3. Assert: stdout does not contain "Could not find gem 'rspec"
    Expected Result: Bundle updates cleanly
    Evidence: bundle output in .sisyphus/evidence/task-2-bundle.txt
  ```

  **Evidence to Capture**:
  - [ ] Gemfile grep outputs in .sisyphus/evidence/task-2-gemfile-check.txt
  - [ ] Bundle install output

  **Commit**: NO (groups with 1)

---

- [x] 3. Convert model test: spec/models/skatepark_spec.rb

  **What to do**:
  - Rename to test/models/skatepark_test.rb
  - Change `RSpec.describe Skatepark` to `class SkateparkTest < ActiveSupport::TestCase`
  - Convert all `it "description"` to `def test_description`
  - Replace `expect(x).to be false` with `assert_equal false, x`
  - Replace `expect(x).to be true` with `assert_equal true, x`
  - Replace `expect(x).to eq(y)` with `assert_equal y, x`
  - Remove `describe 'validations'` wrapper (just test methods)
  - Keep FactoryBot calls: `build(:skatepark)`, `create(:skatepark)`
  - Remove `aggregate_failures` blocks (Minitest shows all failures)

  **Must NOT do**:
  - Use Minitest::Spec DSL (describe/it)
  - Change test data or factory definitions
  - Add new test cases (migration only)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Mechanical syntax translation of single file
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Pattern-based text transformation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 4, 5, 6, 7)
  - **Blocks**: Task 10 (cleanup)
  - **Blocked By**: Task 1 (needs test_helper.rb)

  **References**:
  - `spec/models/skatepark_spec.rb:1-72` - File to convert
  - Draft `.sisyphus/drafts/rspec-to-minitest-migration.md:Test Conversion Patterns` - RSpec → Minitest mapping
  - Minitest docs: https://docs.seattlerb.org/minitest/ - Assertion reference

  **WHY Each Reference Matters**:
  - skatepark_spec.rb: Source file with all RSpec syntax to translate
  - Draft patterns: Quick reference for syntax transformations
  - Minitest docs: Assertion method signatures

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: Model test file converted and passes
    Tool: Bash (docker rails test)
    Preconditions: test/models/skatepark_test.rb created
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/models/skatepark_test.rb
      2. Assert: exit code 0
      3. Assert: stdout contains "X runs, X assertions, 0 failures, 0 errors"
      4. Assert: number of test runs matches original spec (13 tests)
    Expected Result: All model tests pass
    Failure Indicators: Failures, errors, syntax errors, wrong test count
    Evidence: Test output in .sisyphus/evidence/task-3-model-test.txt

  Scenario: No RSpec syntax remains in converted file
    Tool: Bash (grep)
    Preconditions: File converted
    Steps:
      1. grep -E "(describe|context|it |expect|RSpec)" test/models/skatepark_test.rb && echo "FOUND" || echo "CLEAN"
      2. Assert: stdout contains "CLEAN"
    Expected Result: No RSpec keywords
    Evidence: grep output

  Scenario: Classic Minitest syntax used
    Tool: Bash (grep)
    Preconditions: File converted
    Steps:
      1. grep -q "class SkateparkTest < ActiveSupport::TestCase" test/models/skatepark_test.rb
      2. Assert: exit code 0
      3. grep -c "def test_" test/models/skatepark_test.rb
      4. Assert: count >= 13 (at least 13 test methods)
    Expected Result: Minitest class and test methods present
    Evidence: grep outputs
  ```

  **Evidence to Capture**:
  - [ ] Test run output
  - [ ] Syntax verification

  **Commit**: NO (groups with 4-7)

---

- [x] 4. Convert controller tests (4 files)

  **What to do**:
  - Convert spec/controllers/skateparks_controller_spec.rb → test/controllers/skateparks_controller_test.rb
  - Convert spec/controllers/home_controller_spec.rb → test/controllers/home_controller_test.rb
  - Convert spec/controllers/admin/skateparks_controller_spec.rb → test/controllers/admin/skateparks_controller_test.rb
  - Convert spec/controllers/admin/dashboard_controller_spec.rb → test/controllers/admin/dashboard_controller_test.rb
  - Convert spec/controllers/admin/popular_skateparks_controller_spec.rb → test/controllers/admin/popular_skateparks_controller_test.rb
  - Change class to inherit from `ActionDispatch::IntegrationTest`
  - Keep `get :action` calls as-is (rails-controller-testing supports this)
  - Convert `expect(response).to be_successful` to `assert_response :success`
  - Convert `expect(assigns(:var))` to `assert_not_nil assigns(:var)`
  - Convert `aggregate_failures` blocks to separate assertions
  - Keep shared context requires if exist

  **Must NOT do**:
  - Change from controller-style tests to full integration tests (keep get/post syntax)
  - Modify test scenarios or add new ones
  - Change authentication logic

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Repetitive syntax conversion across multiple files
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Pattern-based conversion

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 5, 6, 7)
  - **Blocks**: Task 10
  - **Blocked By**: Task 1

  **References**:
  - `spec/controllers/skateparks_controller_spec.rb:1-211` - Main controller spec
  - `spec/controllers/home_controller_spec.rb` - Home controller spec
  - `spec/controllers/admin/skateparks_controller_spec.rb` - Admin controller spec
  - `spec/controllers/admin/dashboard_controller_spec.rb` - Dashboard spec
  - `spec/controllers/admin/popular_skateparks_controller_spec.rb` - Popular skateparks spec
  - Draft patterns: RSpec → Minitest response assertion mapping
  - Rails guides: https://guides.rubyonrails.org/testing.html#functional-tests-for-your-controllers - Controller testing

  **WHY Each Reference Matters**:
  - Controller specs: Source files with RSpec controller test syntax
  - Rails guides: Minitest controller test patterns and response assertions

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: All controller tests converted and pass
    Tool: Bash (docker rails test)
    Preconditions: All controller test files converted
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/controllers/
      2. Assert: exit code 0
      3. Assert: stdout contains "X runs, X assertions, 0 failures, 0 errors"
      4. Assert: test count matches original specs (~40+ tests)
    Expected Result: All controller tests pass
    Failure Indicators: Failures, errors, wrong test count
    Evidence: .sisyphus/evidence/task-4-controller-tests.txt

  Scenario: Controller test syntax properly converted
    Tool: Bash (grep check)
    Preconditions: Files converted
    Steps:
      1. grep -r "ActionDispatch::IntegrationTest" test/controllers/
      2. Assert: Found in all 5 files
      3. grep -r "assert_response" test/controllers/ | wc -l
      4. Assert: count > 10 (response assertions present)
    Expected Result: Minitest controller syntax used
    Evidence: grep outputs
  ```

  **Evidence to Capture**:
  - [ ] Controller test suite output
  - [ ] Syntax check results

  **Commit**: NO (groups with 3, 5-7)

---

- [x] 5. Convert component tests (8 files)

  **What to do**:
  - Convert all spec/components/_\_spec.rb → test/components/_\_test.rb (8 files)
  - Change from `RSpec.describe XComponent, type: :component` to `class XComponentTest < ViewComponent::TestCase`
  - Convert `it "description"` to `def test_description`
  - Keep `render_inline(component)` calls (ViewComponent API same)
  - Keep Capybara matchers: `have_button`, `have_selector` (Capybara works with Minitest)
  - Convert `expect(rendered).to have_button(...)` to `assert_selector rendered, 'button', text: ...` OR keep Capybara matcher style
  - Convert `expect(html).to include('class')` to `assert_includes html, 'class'`
  - Remove `aggregate_failures` blocks
  - Keep `ViewComponent::TestHelpers` include (works with Minitest)

  **Must NOT do**:
  - Change component rendering logic
  - Modify component test scenarios
  - Add new test coverage

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Pattern-based conversion, ViewComponent Minitest support is straightforward
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Mechanical syntax transformation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 4, 6, 7)
  - **Blocks**: Task 10
  - **Blocked By**: Task 1

  **References**:
  - `spec/components/button_component_spec.rb:1-102` - Example component spec
  - `spec/components/table_component_spec.rb` - Table component spec
  - `spec/components/select_component_spec.rb` - Select component spec
  - `spec/components/link_button_component_spec.rb` - Link button spec
  - `spec/components/link_component_spec.rb` - Link component spec
  - `spec/components/icon_button_component_spec.rb` - Icon button spec
  - `spec/components/homepage_skatepark_card_component_spec.rb` - Card component spec
  - ViewComponent docs: https://viewcomponent.org/guide/testing.html - Minitest testing guide
  - Draft patterns: RSpec → Minitest Capybara matcher handling

  **WHY Each Reference Matters**:
  - Component specs: Source files with ViewComponent + RSpec patterns
  - ViewComponent docs: Shows ViewComponent::TestCase setup and Minitest integration
  - Draft: Capybara matcher compatibility notes

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: All component tests converted and pass
    Tool: Bash (docker rails test)
    Preconditions: Component test files converted
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/components/
      2. Assert: exit code 0
      3. Assert: stdout contains "X runs, X assertions, 0 failures, 0 errors"
      4. Assert: 8 test files run
    Expected Result: All component tests pass
    Failure Indicators: Failures, errors, missing test files
    Evidence: .sisyphus/evidence/task-5-component-tests.txt

  Scenario: ViewComponent TestCase used
    Tool: Bash (grep)
    Preconditions: Files converted
    Steps:
      1. grep -r "ViewComponent::TestCase" test/components/ | wc -l
      2. Assert: count = 8 (all files use TestCase)
    Expected Result: Proper ViewComponent Minitest integration
    Evidence: grep count
  ```

  **Evidence to Capture**:
  - [ ] Component test suite output
  - [ ] TestCase inheritance check

  **Commit**: NO (groups with 3, 4, 6, 7)

---

- [x] 6. Convert system/integration tests (if exist)

  **What to do**:
  - Check if spec/system/ or spec/features/ directories exist
  - If exist: Convert to test/system/ with `ActionDispatch::SystemTestCase`
  - Configure Capybara driven_by in test_helper if needed
  - Convert system test syntax from RSpec to Minitest
  - If no system tests exist: Create empty test/system/.keep file

  **Must NOT do**:
  - Create new system tests (migration only)
  - Change Capybara driver configuration if not needed

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: May be empty task if no system tests exist
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Conditional file conversion

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 4, 5, 7)
  - **Blocks**: Task 10
  - **Blocked By**: Task 1

  **References**:
  - `spec/system/` or `spec/features/` - Check if directories exist
  - Rails guides: https://guides.rubyonrails.org/testing.html#system-testing - System test setup

  **WHY Each Reference Matters**:
  - Spec directories: Determine if system tests need conversion
  - Rails guides: SystemTestCase setup if needed

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: System test directory handled
    Tool: Bash (ls and test)
    Preconditions: Check performed
    Steps:
      1. ls spec/system/ 2>/dev/null || echo "NO_SYSTEM_TESTS"
      2. If system tests exist: docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/system/
      3. If not: ls test/system/.keep
      4. Assert: Either tests pass OR .keep file exists
    Expected Result: System tests converted or marked as N/A
    Evidence: .sisyphus/evidence/task-6-system-tests.txt
  ```

  **Evidence to Capture**:
  - [ ] System test check output

  **Commit**: NO (groups with 3-5, 7)

---

- [x] 7. Convert job/worker/helper/mailer/channel tests (7 files)

  **What to do**:
  - Convert spec/jobs/application_job_spec.rb → test/jobs/application_job_test.rb
  - Convert spec/workers/sitemap_worker_spec.rb → test/jobs/sitemap_worker_test.rb (note: workers go in test/jobs/)
  - Convert spec/helpers/locale_helper_spec.rb → test/helpers/locale_helper_test.rb
  - Convert spec/helpers/schema_helper_spec.rb → test/helpers/schema_helper_test.rb
  - Convert spec/mailers/application_mailer_spec.rb → test/mailers/application_mailer_test.rb
  - Convert spec/channels/application_cable/connection_spec.rb → test/channels/application_cable/connection_test.rb
  - Convert spec/channels/application_cable/channel_spec.rb → test/channels/application_cable/channel_test.rb
  - Use appropriate test case classes: ActiveSupport::TestCase for jobs, ActionMailer::TestCase for mailers, etc.
  - Convert all RSpec syntax to Minitest

  **Must NOT do**:
  - Change job/mailer/channel logic
  - Add new test scenarios

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Multiple small files with standard Rails patterns
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Rails test conventions well-documented

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 4, 5, 6)
  - **Blocks**: Task 10
  - **Blocked By**: Task 1

  **References**:
  - `spec/jobs/application_job_spec.rb` - Job spec
  - `spec/workers/sitemap_worker_spec.rb` - Worker spec
  - `spec/helpers/locale_helper_spec.rb` - Locale helper spec
  - `spec/helpers/schema_helper_spec.rb` - Schema helper spec
  - `spec/mailers/application_mailer_spec.rb` - Mailer spec
  - `spec/channels/application_cable/connection_spec.rb` - Connection spec
  - `spec/channels/application_cable/channel_spec.rb` - Channel spec
  - Rails guides: https://guides.rubyonrails.org/testing.html - Job/mailer/channel test patterns

  **WHY Each Reference Matters**:
  - Spec files: Source files for conversion
  - Rails guides: Minitest patterns for each Rails component type

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: All job/worker/helper/mailer/channel tests pass
    Tool: Bash (docker rails test)
    Preconditions: All files converted
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test test/jobs/ test/helpers/ test/mailers/ test/channels/
      2. Assert: exit code 0
      3. Assert: stdout contains "X runs, X assertions, 0 failures, 0 errors"
      4. Assert: 7 test files run
    Expected Result: All tests pass
    Evidence: .sisyphus/evidence/task-7-misc-tests.txt
  ```

  **Evidence to Capture**:
  - [ ] Combined test output

  **Commit**: YES
  - Message: `test: migrate RSpec to Minitest (all test files converted)`
  - Files: `test/**/*_test.rb`, `test/test_helper.rb`, `Gemfile`, `Gemfile.lock`
  - Pre-commit: `docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test`

---

- [x] 8. Update RuboCop config (remove RSpec plugins)

  **What to do**:
  - Edit .rubocop.yml
  - Remove `rubocop-rspec` from plugins section
  - Remove `rubocop-rspec_rails` from plugins section
  - Remove all `RSpec/*` configuration sections
  - Update `Metrics/MethodLength` and `Metrics/BlockLength` excludes from `spec/**/*` to `test/**/*`
  - Keep rubocop-capybara and rubocop-factory_bot (work with Minitest)
  - Run bundle exec rubocop -A to verify config valid

  **Must NOT do**:
  - Remove rubocop-rails
  - Remove rubocop-capybara (still needed)
  - Remove rubocop-factory_bot (still needed)
  - Change other RuboCop rules

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Simple YAML configuration update
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: YAML editing

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 9)
  - **Blocks**: None
  - **Blocked By**: Task 2 (gems removed from Gemfile)

  **References**:
  - `.rubocop.yml:1-74` - Current RuboCop configuration
  - `.rubocop.yml:7-8` - RSpec plugins to remove
  - `.rubocop.yml:27-33` - Metrics excludes to update (spec → test)
  - `.rubocop.yml:56-72` - RSpec/\* rules to remove

  **WHY Each Reference Matters**:
  - .rubocop.yml: Shows exact plugins and rules to remove
  - Metrics sections: Path excludes need updating for new test/ directory

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: RuboCop config valid without RSpec plugins
    Tool: Bash (docker rubocop)
    Preconditions: .rubocop.yml updated
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bundle exec rubocop --version
      2. Assert: exit code 0
      3. grep -q "rubocop-rspec" .rubocop.yml && echo "FOUND" || echo "REMOVED"
      4. Assert: stdout contains "REMOVED"
    Expected Result: RSpec plugins removed, config valid
    Evidence: .sisyphus/evidence/task-8-rubocop-config.txt

  Scenario: RuboCop runs successfully
    Tool: Bash (docker rubocop)
    Preconditions: Config updated
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bundle exec rubocop test/ --format simple
      2. Assert: No plugin loading errors
      3. Assert: exit code 0 or 1 (0=clean, 1=offenses, both OK; error codes mean config broken)
    Expected Result: RuboCop processes test files
    Evidence: RuboCop output
  ```

  **Evidence to Capture**:
  - [ ] RuboCop config check
  - [ ] RuboCop test run

  **Commit**: YES
  - Message: `chore: update RuboCop config for Minitest`
  - Files: `.rubocop.yml`
  - Pre-commit: `bundle exec rubocop --version`

---

- [x] 9. Update Docker test commands in scripts.sh

  **What to do**:
  - Edit scripts.sh
  - Find RSpec test command (likely contains `bundle exec rspec`)
  - Replace with `bin/rails test` or `bundle exec rails test`
  - Update any menu text from "Run RSpec tests" to "Run tests"
  - Verify command works in Docker context

  **Must NOT do**:
  - Change other script commands
  - Modify Docker compose files (unless test command broken)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Simple shell script update
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Bash scripting

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 8)
  - **Blocks**: None
  - **Blocked By**: Tasks 3-7 (test files must exist)

  **References**:
  - `scripts.sh` - Script containing test commands
  - `docker-compose.test.yml` - Test environment config
  - README.md: Shows current test execution workflow

  **WHY Each Reference Matters**:
  - scripts.sh: Contains RSpec command to replace
  - docker-compose.test.yml: Verify service name and command context

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: Test command in scripts.sh updated
    Tool: Bash (grep)
    Preconditions: scripts.sh edited
    Steps:
      1. grep -q "bundle exec rspec" scripts.sh && echo "RSPEC_FOUND" || echo "REPLACED"
      2. Assert: stdout contains "REPLACED"
      3. grep -q "bin/rails test" scripts.sh || grep -q "bundle exec rails test" scripts.sh
      4. Assert: exit code 0 (new command found)
    Expected Result: RSpec command replaced with Minitest
    Evidence: .sisyphus/evidence/task-9-scripts-check.txt

  Scenario: Test command executes successfully
    Tool: Bash (docker test)
    Preconditions: Command updated, all tests converted
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test
      2. Assert: exit code 0
      3. Assert: stdout shows test summary (X runs, X assertions)
    Expected Result: Full test suite passes
    Evidence: .sisyphus/evidence/task-9-full-test-run.txt
  ```

  **Evidence to Capture**:
  - [ ] scripts.sh verification
  - [ ] Full test suite run

  **Commit**: YES
  - Message: `chore: update test commands for Minitest`
  - Files: `scripts.sh`
  - Pre-commit: `docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test`

---

- [x] 10. Remove spec/ directory and RSpec config files

  **What to do**:
  - Remove spec/ directory recursively
  - Remove .rspec file
  - Remove spec/spec_helper.rb (if not already removed)
  - Remove spec/rails_helper.rb (if not already removed)
  - Remove spec/support/ directory
  - Verify no RSpec references remain in codebase

  **Must NOT do**:
  - Remove test/ directory
  - Remove factory definitions (moved to test/factories/)
  - Remove fixtures (moved to test/fixtures/)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: File/directory cleanup
  - **Skills**: None required
  - **Skills Evaluated but Omitted**:
    - All skills: Basic file operations

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3 (final cleanup, sequential)
  - **Blocks**: None (final task)
  - **Blocked By**: Tasks 2-9 (all migration complete)

  **References**:
  - `spec/` - Directory to remove
  - `.rspec` - Config file to remove

  **WHY Each Reference Matters**:
  - spec/: Old RSpec test directory, no longer needed
  - .rspec: RSpec runner configuration, obsolete

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios**:

  ```
  Scenario: spec/ directory and RSpec files removed
    Tool: Bash (ls)
    Preconditions: Removal complete
    Steps:
      1. ls spec/ 2>&1 | grep -q "No such file or directory"
      2. Assert: spec/ directory doesn't exist
      3. ls .rspec 2>&1 | grep -q "No such file or directory"
      4. Assert: .rspec file doesn't exist
    Expected Result: RSpec artifacts gone
    Evidence: .sisyphus/evidence/task-10-cleanup.txt

  Scenario: No RSpec references in codebase
    Tool: Bash (grep)
    Preconditions: Cleanup complete
    Steps:
      1. grep -r "require.*rspec" app/ config/ lib/ test/ 2>/dev/null || echo "CLEAN"
      2. Assert: stdout contains "CLEAN" (no matches)
    Expected Result: Codebase free of RSpec requires
    Evidence: grep output

  Scenario: Test suite still passes after cleanup
    Tool: Bash (docker test)
    Preconditions: All RSpec artifacts removed
    Steps:
      1. docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test
      2. Assert: exit code 0
      3. Assert: All 20+ tests pass
    Expected Result: Minitest fully functional
    Evidence: Final test run output
  ```

  **Evidence to Capture**:
  - [ ] Directory removal verification
  - [ ] Final test suite output

  **Commit**: YES
  - Message: `chore: remove RSpec artifacts (migration complete)`
  - Files: Removed `spec/`, `.rspec`
  - Pre-commit: `docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test`

---

## Commit Strategy

| After Task | Message                                                    | Files                             | Verification      |
| ---------- | ---------------------------------------------------------- | --------------------------------- | ----------------- |
| 7          | test: migrate RSpec to Minitest (all test files converted) | test/, Gemfile, Gemfile.lock      | bin/rails test    |
| 8          | chore: update RuboCop config for Minitest                  | .rubocop.yml                      | rubocop --version |
| 9          | chore: update test commands for Minitest                   | scripts.sh                        | bin/rails test    |
| 10         | chore: remove RSpec artifacts (migration complete)         | spec/ (removed), .rspec (removed) | bin/rails test    |

---

## Success Criteria

### Verification Commands

```bash
# All tests pass in Docker
docker compose -f docker-compose.test.yml exec skateparks-web-test bin/rails test

# RuboCop passes
docker compose -f docker-compose.test.yml exec skateparks-web-test bundle exec rubocop

# No RSpec gems in bundle
docker compose -f docker-compose.test.yml exec skateparks-web-test bundle list | grep -i rspec
# Expected: no output (exit code 1)

# Coverage enabled
grep -q "Coverage.start" test/test_helper.rb
# Expected: exit code 0
```

### Final Checklist

- [x] All 20 test files converted from RSpec to Minitest
- [x] test/test_helper.rb configured with FactoryBot, Capybara, native coverage
- [x] No RSpec gems in Gemfile
- [x] RuboCop config updated (no RSpec plugins)
- [x] Docker test commands use bin/rails test
- [x] spec/ directory removed
- [x] All tests pass: `bin/rails test` exits 0
- [x] RuboCop passes with updated config

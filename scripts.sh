#!/bin/bash

# Docs invoke this as `sh scripts.sh`; leave POSIX mode so `echo -e` colors work.
set +o posix 2>/dev/null || true

# Use the Node version pinned in .nvmrc/.node-version for project tooling, even
# when the calling shell has not loaded nvm (non-interactive shells, IDEs, agents).
use_project_node() {
    local version node_bin
    version=$(cat .nvmrc 2>/dev/null || cat .node-version 2>/dev/null)
    version="${version#v}"
    [ -n "$version" ] || return 0
    node_bin="${NVM_DIR:-$HOME/.nvm}/versions/node/v${version}/bin"
    if [ -x "$node_bin/node" ]; then
        PATH="$node_bin:$PATH"
        export PATH
    fi
}

use_project_node

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

COMPOSE_FILE="./docker-compose.yml"
TEST_ENV_FILE="./.env.test"
SERVICE_NAME="skateparks-web"
DB_SERVICE_NAME="skateparks-db"
REDIS_SERVICE_NAME="skateparks-redis"
WEB_IMAGE="skateparks-dev"

INTERACTIVE=true

check_docker() {
    if ! docker info > /dev/null 2>&1; then
        printf "${RED}Error: Docker is not running. Please start Docker first.${NC}\n"
        exit 1
    fi
}

app_compose() {
    docker compose -f "$COMPOSE_FILE" "$@"
}

service_exists() {
    app_compose ps -a --services 2>/dev/null | grep -qx "$1"
}

ensure_web_image() {
    if ! docker image inspect "$WEB_IMAGE" > /dev/null 2>&1; then
        echo -e "${GREEN}Building development image...${NC}"
        app_compose build "$SERVICE_NAME" || return 1
    fi
}

ensure_infra() {
    app_compose up -d --wait "$DB_SERVICE_NAME" "$REDIS_SERVICE_NAME"
}

# Run a command in a disposable container built from the development image,
# with the test environment from .env.test (database and Redis isolation).
test_run() {
    ensure_web_image || return 1
    ensure_infra || return 1
    app_compose run --rm -T --env-from-file "$TEST_ENV_FILE" "$SERVICE_NAME" "$@"
}

# Same as test_run but keeps a TTY for interactive console/bash sessions.
test_run_interactive() {
    ensure_web_image || return 1
    ensure_infra || return 1
    app_compose run --rm --env-from-file "$TEST_ENV_FILE" "$SERVICE_NAME" "$@"
}

show_docker_status() {
    echo -e "${CYAN}--- Docker Status ---${NC}"
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(skateparks|rails|postgres)" > /dev/null 2>&1; then
        docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(skateparks|rails|postgres)" | head -10
    else
        echo -e "${YELLOW}No skatepark containers currently running${NC}"
    fi
    echo ""
}

confirm_action() {
    local message="$1"
    local require_force="${2:-false}"

    if [ "$INTERACTIVE" = false ]; then
        if [ "$require_force" = true ] && [ "${FORCE:-false}" != true ]; then
            echo -e "${RED}Destructive action requires --force in non-interactive mode.${NC}"
            return 1
        fi
        return 0
    fi
    echo -e "${YELLOW}$message${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

operation_completed() {
    echo -e "${GREEN}Operation completed!${NC}"
}

# --- Development server ---

start_dev_server() {
    local rebuild="${1:-false}"

    if [ "$rebuild" = true ]; then
        if ! confirm_action "This will rebuild and recreate the development container." true; then
            echo -e "${RED}Operation cancelled.${NC}"
            return 0
        fi
        echo -e "${GREEN}Building and starting development server with fresh build...${NC}"
        if app_compose up --remove-orphans --build --force-recreate -d; then
            echo -e "${GREEN}✅ Development server built and started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to build and start development server${NC}"
            return 1
        fi
        return 0
    fi

    if service_exists "$SERVICE_NAME"; then
        echo -e "${GREEN}Starting development server...${NC}"
        if app_compose start; then
            echo -e "${GREEN}✅ Development server started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to start development server${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}No existing development containers. Building and starting...${NC}"
        if app_compose up --remove-orphans --build -d; then
            echo -e "${GREEN}✅ Development server built and started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to build and start development server${NC}"
            return 1
        fi
    fi
}

interactive_start_dev_server() {
    echo -e "${YELLOW}Rebuild from scratch? (y/N):${NC} "
    read -r -n 1 REBUILD_REPLY
    echo
    if [[ $REBUILD_REPLY =~ ^[Yy]$ ]]; then
        start_dev_server true
    else
        start_dev_server false
    fi
}

view_dev_logs() {
    echo -e "${GREEN}Viewing development server logs...${NC}"
    app_compose logs -f "$SERVICE_NAME"
}

dev_rails_console() {
    echo -e "${GREEN}Opening Rails console...${NC}"
    app_compose exec "$SERVICE_NAME" bundle exec rails console
}

dev_bash_shell() {
    echo -e "${GREEN}Connecting to development Docker console...${NC}"
    app_compose exec "$SERVICE_NAME" bash
}

stop_dev_server() {
    if ! confirm_action "This will stop the development server."; then
        echo -e "${RED}Operation cancelled.${NC}"
        return 0
    fi
    echo -e "${YELLOW}Stopping development server...${NC}"
    if app_compose stop; then
        echo -e "${GREEN}✅ Development server stopped${NC}"
    else
        echo -e "${RED}❌ Failed to stop development server${NC}"
        return 1
    fi
}

# --- Test environment ---

prepare_test_database() {
    echo -e "${GREEN}Preparing test database...${NC}"
    if test_run bin/rails db:prepare; then
        echo -e "${GREEN}✅ Test database ready${NC}"
    else
        echo -e "${RED}❌ Failed to prepare test database${NC}"
        return 1
    fi
}

start_test_environment() {
    local rebuild="${1:-false}"

    if [ "$rebuild" = true ]; then
        if ! confirm_action "This will rebuild the development image used by test runs." true; then
            echo -e "${RED}Operation cancelled.${NC}"
            return 0
        fi
        echo -e "${GREEN}Rebuilding development image...${NC}"
        if ! app_compose build "$SERVICE_NAME"; then
            echo -e "${RED}❌ Failed to rebuild development image${NC}"
            return 1
        fi
    fi

    prepare_test_database
}

test_rails_console() {
    echo -e "${GREEN}Opening test Rails console...${NC}"
    test_run_interactive bin/rails console
}

test_bash_shell() {
    echo -e "${GREEN}Connecting to test Docker console...${NC}"
    test_run_interactive bash
}

# --- Tests ---

run_tests_with_coverage() {
    echo -e "${GREEN}Running tests with coverage...${NC}"
    if test_run bash -c "bin/rails db:prepare && rm -rf coverage && bin/rails test"; then
        echo ""
        echo -e "${CYAN}Coverage report: ${NC}file://$(pwd)/coverage/index.html"
    else
        return 1
    fi
}

run_tests_fast() {
    echo -e "${GREEN}Running tests without coverage...${NC}"
    test_run bash -c "bin/rails db:prepare && DISABLE_SIMPLECOV=1 bin/rails test"
}

run_single_test() {
    local target="$1"

    if [ -z "$target" ]; then
        if [ "$INTERACTIVE" = true ]; then
            read -r -p "Test path (e.g. test/models/skatepark_test.rb or test/models/skatepark_test.rb:42): " target
        else
            echo -e "${RED}Test path required. Usage: scripts.sh test <path>${NC}"
            return 1
        fi
    fi

    if [ -z "$target" ]; then
        echo -e "${RED}No test path provided.${NC}"
        return 1
    fi

    echo -e "${GREEN}Running test: ${target}${NC}"
    test_run bash -c 'bin/rails db:prepare && bin/rails test "$@"' bash "$target"
}

run_tests_cli() {
    case "${1:-}" in
        --fast)
            run_tests_fast
            ;;
        "")
            run_tests_with_coverage
            ;;
        *)
            run_single_test "$1"
            ;;
    esac
}

interactive_run_single_test() {
    read -r -p "Test path (e.g. test/models/skatepark_test.rb or test/models/skatepark_test.rb:42): " target
    run_single_test "$target"
}

# --- Changed-file helpers (fast path for simple commits) ---

# List worktree + branch changes vs base (default: main), one path per line.
changed_files_list() {
    local base="${1:-main}"

    if git rev-parse --verify --quiet "$base" > /dev/null; then
        git diff --name-only "$base"...HEAD 2>/dev/null
    fi
    git diff --name-only 2>/dev/null
    git diff --cached --name-only 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
}

# Dedupe stdin lines, drop empties.
dedupe_lines() {
    sort -u | grep -v '^$' || true
}

# Map app Ruby files to their conventional test file (echo if it exists).
map_app_file_to_test() {
    local file="$1"
    local candidate=""

    case "$file" in
        test/*_test.rb)
            candidate="$file"
            ;;
        app/models/*.rb|app/controllers/*.rb|app/components/*.rb|app/helpers/*.rb|app/jobs/*.rb|app/mailers/*.rb)
            candidate="test/${file#app/}"
            candidate="${candidate%.rb}_test.rb"
            ;;
    esac

    if [ -n "$candidate" ] && [ -f "$candidate" ]; then
        echo "$candidate"
    fi
}

# Returns 0 when the change set needs a full suite (migrations, schema,
# Gemfile, factories, test helpers, or too many files to target).
needs_full_suite() {
    local file="$1"

    case "$file" in
        Gemfile|Gemfile.lock|db/schema.rb|db/migrate/*|config/application.rb|config/database.yml|config/environments/test.rb|Dockerfile.development|docker-compose.yml|.env.test|test/test_helper.rb|test/support/*|test/factories/*)
            return 0
            ;;
    esac
    return 1
}

run_tests_changed() {
    local base="main"
    if [ "${1:-}" = "--base" ] && [ -n "${2:-}" ]; then
        base="$2"
    elif [ -n "${1:-}" ] && [ "${1#-}" = "$1" ]; then
        base="$1"
    fi

    local files
    files=$(changed_files_list "$base" | dedupe_lines)

    if [ -z "$files" ]; then
        echo -e "${YELLOW}No changed files vs ${base}; nothing to test.${NC}"
        return 0
    fi

    local count
    count=$(printf '%s\n' "$files" | wc -l | tr -d ' ')
    if [ "$count" -gt 10 ]; then
        echo -e "${YELLOW}${count} changed files — falling back to full fast suite.${NC}"
        run_tests_fast
        return $?
    fi

    local tests=""
    local file
    while IFS= read -r file; do
        if needs_full_suite "$file"; then
            echo -e "${YELLOW}${file} requires full suite — falling back to test --fast.${NC}"
            run_tests_fast
            return $?
        fi
        mapped=$(map_app_file_to_test "$file")
        if [ -n "$mapped" ]; then
            tests=$(printf '%s\n%s' "$tests" "$mapped" | grep -v '^$' | sort -u)
        fi
    done <<< "$files"

    if [ -z "$tests" ]; then
        echo -e "${YELLOW}No mappable tests for changed files (views/locales/CSS only). Lint covers this; skipping targeted tests.${NC}"
        return 0
    fi

    echo -e "${GREEN}Running targeted tests:${NC}"
    echo "$tests"
    # shellcheck disable=SC2086
    test_run bash -c "bin/rails db:prepare && DISABLE_SIMPLECOV=1 bin/rails test $tests"
}

run_lint_changed() {
    local base="main"
    if [ "${1:-}" = "--base" ] && [ -n "${2:-}" ]; then
        base="$2"
    elif [ -n "${1:-}" ] && [ "${1#-}" = "$1" ]; then
        base="$1"
    fi

    local files
    files=$(changed_files_list "$base" | dedupe_lines)

    if [ -z "$files" ]; then
        echo -e "${YELLOW}No changed files vs ${base}; nothing to lint.${NC}"
        return 0
    fi

    local rb_files=""
    local erb_files=""
    local prettier_files=""
    local file
    while IFS= read -r file; do
        [ -f "$file" ] || continue
        case "$file" in
            *.rb)
                rb_files="$rb_files $file"
                ;;
            *.erb)
                erb_files="$erb_files $file"
                ;;
            *.js|*.ts|*.json|*.css|*.md)
                prettier_files="$prettier_files $file"
                ;;
        esac
    done <<< "$files"

    if [ -z "$rb_files$erb_files$prettier_files" ]; then
        echo -e "${YELLOW}No lintable changed files (no rb/erb/js/ts/json/css/md).${NC}"
        return 0
    fi

    local -a specs=()
    # shellcheck disable=SC2086
    [ -n "$rb_files" ] && specs+=("RuboCop changed::bundle exec rubocop --force-exclusion --parallel $rb_files")
    # shellcheck disable=SC2086
    [ -n "$erb_files" ] && specs+=("Herb lint changed::pnpm exec herb-lint $erb_files")
    # shellcheck disable=SC2086
    [ -n "$erb_files" ] && specs+=("Herb format changed::pnpm exec herb-format --check $erb_files")
    # shellcheck disable=SC2086
    [ -n "$prettier_files" ] && specs+=("Prettier changed::pnpm exec prettier --check $prettier_files")

    echo -e "${GREEN}Running changed-file linters...${NC}"
    if run_checks_parallel "${specs[@]}"; then
        echo -e "${GREEN}✅ Changed-file linters passed${NC}"
    else
        echo -e "${RED}❌ Changed-file linters failed${NC}"
        return 1
    fi
}

run_gate_quick() {
    local base="${1:-main}"
    if [ "${1:-}" = "--base" ]; then
        base="${2:-main}"
    fi

    run_lint_changed "$base" || return 1
    run_tests_changed "$base"
}

# --- Linting & security ---

RUBOCOP_CMD="bundle exec rubocop --force-exclusion --parallel"

run_checks_parallel() {
    local failed=false
    local tmpdir
    tmpdir=$(mktemp -d)

    local -a names=()
    local -a pids=()

    for spec in "$@"; do
        local name="${spec%%::*}"
        local cmd="${spec#*::}"
        local slug
        slug=$(printf '%s' "$name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')

        names+=("$name")
        (
            eval "$cmd" > "$tmpdir/${slug}.log" 2>&1
            echo $? > "$tmpdir/${slug}.status"
        ) &
        pids+=($!)
    done

    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done

    for spec in "$@"; do
        local name="${spec%%::*}"
        local slug
        slug=$(printf '%s' "$name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
        local status
        status=$(cat "$tmpdir/${slug}.status")

        if [ "$status" -eq 0 ]; then
            echo -e "${GREEN}✅ ${name} passed${NC}"
        else
            echo -e "${RED}❌ ${name} failed${NC}"
            cat "$tmpdir/${slug}.log"
            failed=true
        fi
    done

    rm -rf "$tmpdir"

    if [ "$failed" = true ]; then
        return 1
    fi
}

run_linters_check() {
    echo -e "${GREEN}Running linters in parallel (RuboCop, Prettier, Herb)...${NC}"

    if run_checks_parallel \
        "RuboCop::${RUBOCOP_CMD}" \
        "Prettier::pnpm prettier:check" \
        "Herb lint::pnpm herb:lint" \
        "Herb format::pnpm herb:format:check"; then
        echo -e "${GREEN}✅ All linter checks passed${NC}"
    else
        echo -e "${RED}❌ Linter checks failed${NC}"
        return 1
    fi
}

run_linters_check_full() {
    echo -e "${GREEN}Running full linter checks in parallel (includes Zeitwerk)...${NC}"

    if run_checks_parallel \
        "Zeitwerk::bundle exec rails zeitwerk:check" \
        "RuboCop::${RUBOCOP_CMD}" \
        "Prettier::pnpm prettier:check" \
        "Herb lint::pnpm herb:lint" \
        "Herb format::pnpm herb:format:check"; then
        echo -e "${GREEN}✅ All linter checks passed${NC}"
    else
        echo -e "${RED}❌ Linter checks failed${NC}"
        return 1
    fi
}

run_linters_fix() {
    echo -e "${GREEN}Running RuboCop auto-fix...${NC}"
    bundle exec rubocop -A --force-exclusion --parallel || true

    echo -e "${GREEN}Formatting with Prettier...${NC}"
    pnpm prettier:fix || true

    echo -e "${GREEN}Formatting ERB files with Herb...${NC}"
    pnpm herb:format || true

    echo -e "${GREEN}Running Herb lint auto-fix...${NC}"
    pnpm herb:lint:fix || true

    echo -e "${GREEN}Re-running linter checks...${NC}"
    run_linters_check
}

run_security_audits() {
    echo -e "${GREEN}Running security audits in parallel...${NC}"

    if run_checks_parallel \
        "Brakeman::bundle exec brakeman -q --no-pager" \
        "Bundle audit::bundle exec bundle-audit check --update" \
        "pnpm audit::pnpm audit --audit-level moderate"; then
        echo -e "${GREEN}✅ All security audits passed${NC}"
    else
        return 1
    fi
}

run_ci_checks() {
    echo -e "${GREEN}Running CI parity checks in parallel...${NC}"

    if run_checks_parallel \
        "Zeitwerk::bundle exec rails zeitwerk:check" \
        "RuboCop::${RUBOCOP_CMD}" \
        "Prettier::pnpm prettier:check" \
        "Herb lint::pnpm herb:lint" \
        "Herb format::pnpm herb:format:check" \
        "Brakeman::bundle exec brakeman -q --no-pager" \
        "Bundle audit::bundle exec bundle-audit check --update" \
        "pnpm audit::pnpm audit --audit-level moderate"; then
        echo -e "${GREEN}✅ All CI parity checks passed${NC}"
    else
        echo -e "${RED}❌ CI parity checks failed${NC}"
        return 1
    fi
}

run_linters_cli() {
    case "${1:-}" in
        --fix)
            run_linters_fix
            ;;
        --full)
            run_linters_check_full
            ;;
        *)
            run_linters_check
            ;;
    esac
}

# --- Database & cache ---

migrate_database() {
    echo -e "${GREEN}Running database migrations...${NC}"
    if app_compose exec "$SERVICE_NAME" bash -c "bundle exec rails db:migrate"; then
        echo -e "${GREEN}✅ Database migrated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to migrate database${NC}"
        return 1
    fi
}

seed_database() {
    echo -e "${GREEN}Seeding the database...${NC}"
    if app_compose exec "$SERVICE_NAME" bash -c "bundle exec rails db:seed"; then
        echo -e "${GREEN}✅ Database seeded successfully${NC}"
    else
        echo -e "${RED}❌ Failed to seed database${NC}"
        return 1
    fi
}

reset_database() {
    if ! confirm_action "This will reset the database. All data will be lost!" true; then
        echo -e "${RED}Operation cancelled.${NC}"
        return 0
    fi
    echo -e "${GREEN}Resetting database...${NC}"
    if app_compose exec "$SERVICE_NAME" bash -c "bundle exec rails db:reset"; then
        echo -e "${GREEN}✅ Database reset successfully${NC}"
    else
        echo -e "${RED}❌ Failed to reset database${NC}"
        return 1
    fi
}

clear_rails_cache() {
    echo -e "${GREEN}Clearing Rails cache...${NC}"
    if app_compose exec "$SERVICE_NAME" bash -c "bundle exec rails runner 'Rails.cache.clear'"; then
        echo -e "${GREEN}✅ Cache cleared successfully${NC}"
    else
        echo -e "${RED}❌ Failed to clear cache${NC}"
        return 1
    fi
}

reload_test_schema() {
    echo -e "${GREEN}Reloading test database schema...${NC}"
    if test_run bin/rails db:create db:schema:load; then
        echo -e "${GREEN}✅ Test database schema loaded successfully${NC}"
    else
        echo -e "${RED}❌ Failed to load test database schema${NC}"
        return 1
    fi
}

stop_all_containers() {
    if ! confirm_action "This will stop all skateparks-related Docker containers."; then
        echo -e "${RED}Operation cancelled.${NC}"
        return 0
    fi
    echo -e "${YELLOW}Stopping skateparks Docker containers...${NC}"
    if app_compose stop; then
        echo -e "${GREEN}✅ Skateparks containers stopped${NC}"
    else
        echo -e "${YELLOW}⚠️  No skateparks containers were running${NC}"
    fi
}

# --- CLI ---

show_help() {
    cat <<EOF
Skateparks.gr Development Toolkit

Usage:
  scripts.sh                         Interactive menu
  scripts.sh test [--fast] [path]    Run tests (coverage, fast, or single file/line)
  scripts.sh test-changed [--base main]  Targeted tests for changed files (fast path)
  scripts.sh lint [--fix] [--full]       Run linters (fast by default; --full adds Zeitwerk)
  scripts.sh lint-changed [--base main]  Linters on changed files only (fast path)
  scripts.sh gate-quick [--base main]    lint-changed + test-changed (fast path for WIP commits)
  scripts.sh security                  Run all security audits
  scripts.sh ci                        Run all CI parity checks in parallel
  scripts.sh dev <command>             Development server commands
  scripts.sh test-server <command>     Test environment commands (ephemeral containers)

Dev commands:
  up, rebuild, down, logs, console, bash, migrate, seed, reset, cache-clear

Test-environment commands:
  up, rebuild, console, bash, schema-load

Destructive non-interactive commands require --force:
  scripts.sh dev rebuild --force
  scripts.sh dev reset --force
  scripts.sh test-server rebuild --force
EOF
}

run_dev_cli() {
    local command="${1:-}"
    shift || true

    if [ "${1:-}" = "--force" ]; then
        FORCE=true
        shift
    fi

    case "$command" in
        up) start_dev_server false ;;
        rebuild) start_dev_server true ;;
        down) stop_dev_server ;;
        logs) view_dev_logs ;;
        console) dev_rails_console ;;
        bash) dev_bash_shell ;;
        migrate) migrate_database ;;
        seed) seed_database ;;
        reset) reset_database ;;
        cache-clear) clear_rails_cache ;;
        *)
            echo -e "${RED}Unknown dev command: ${command}${NC}"
            show_help
            return 1
            ;;
    esac
}

run_test_server_cli() {
    local command="${1:-}"
    shift || true

    if [ "${1:-}" = "--force" ]; then
        FORCE=true
        shift
    fi

    case "$command" in
        up) start_test_environment false ;;
        rebuild) start_test_environment true ;;
        console) test_rails_console ;;
        bash) test_bash_shell ;;
        schema-load) reload_test_schema ;;
        *)
            echo -e "${RED}Unknown test-server command: ${command}${NC}"
            show_help
            return 1
            ;;
    esac
}

run_cli() {
    INTERACTIVE=false

    case "${1:-}" in
        help|--help|-h)
            show_help
            return 0
            ;;
    esac

    check_docker

    case "${1:-}" in
        test)
            shift
            run_tests_cli "$@"
            ;;
        test-changed)
            shift
            run_tests_changed "$@"
            ;;
        lint)
            shift
            run_linters_cli "$@"
            ;;
        lint-changed)
            shift
            run_lint_changed "$@"
            ;;
        gate-quick)
            shift
            run_gate_quick "$@"
            ;;
        security)
            run_security_audits
            ;;
        ci)
            run_ci_checks
            ;;
        dev)
            shift
            run_dev_cli "$@"
            ;;
        test-server)
            shift
            run_test_server_cli "$@"
            ;;
        *)
            echo -e "${RED}Unknown command: ${1:-}${NC}"
            show_help
            return 1
            ;;
    esac
}

# --- Interactive menu ---

show_menu() {
    echo -e "${PURPLE}🛹 Skateparks.gr Development Toolkit 🛹${NC}"
    echo ""
    show_docker_status

    echo -e "${GREEN}--- Development Server ---${NC}"
    echo -e " ${BLUE}(1)${NC}  Start / rebuild development server"
    echo -e " ${BLUE}(2)${NC}  View development server logs"
    echo -e " ${BLUE}(3)${NC}  Rails console (development)"
    echo -e " ${BLUE}(4)${NC}  Connect to development Docker console"
    echo -e " ${BLUE}(5)${NC}  Stop development server"
    echo ""
    echo -e "${GREEN}--- Test Environment (ephemeral) ---${NC}"
    echo -e " ${BLUE}(6)${NC}  Run all tests (with coverage)"
    echo -e " ${BLUE}(7)${NC}  Run tests (no coverage)"
    echo -e " ${BLUE}(8)${NC}  Run single test"
    echo -e " ${BLUE}(9)${NC}  Rails console (test)"
    echo -e " ${BLUE}(10)${NC} Connect to test Docker console"
    echo -e " ${BLUE}(11)${NC} Prepare test database (schema + migrations)"
    echo ""
    echo -e "${GREEN}--- Tests & Linting & Formatting ---${NC}"
    echo -e " ${BLUE}(12)${NC} Run linters (check, fast)"
    echo -e " ${BLUE}(13)${NC} Run all linters (fix)"
    echo -e " ${BLUE}(14)${NC} Run security audits"
    echo -e " ${BLUE}(15)${NC} Run all CI parity checks (parallel)"
    echo ""
    echo -e "${GREEN}--- Database & Cache ---${NC}"
    echo -e " ${BLUE}(16)${NC} Migrate database"
    echo -e " ${BLUE}(17)${NC} Seed the database"
    echo -e " ${BLUE}(18)${NC} Reset database"
    echo -e " ${BLUE}(19)${NC} Clear all Rails cache"
    echo ""
    echo -e "${GREEN}--- Other ---${NC}"
    echo -e " ${BLUE}(20)${NC} Stop all skateparks Docker containers"
    echo ""
    echo -e "${YELLOW}Choose an option (or q to quit):${NC} "
}

run_menu_option() {
    case "$OPTION" in
        1) interactive_start_dev_server ;;
        2) view_dev_logs ;;
        3) dev_rails_console ;;
        4) dev_bash_shell ;;
        5) stop_dev_server ;;
        6) run_tests_with_coverage ;;
        7) run_tests_fast ;;
        8) interactive_run_single_test ;;
        9) test_rails_console ;;
        10) test_bash_shell ;;
        11) start_test_environment false ;;
        12) run_linters_check ;;
        13) run_linters_fix ;;
        14) run_security_audits ;;
        15) run_ci_checks ;;
        16) migrate_database ;;
        17) seed_database ;;
        18) reset_database ;;
        19) clear_rails_cache ;;
        20) stop_all_containers ;;
        q|Q)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $OPTION${NC}"
            echo -e "${YELLOW}Please choose a valid option (1-20) or q to quit${NC}"
            return 1
            ;;
    esac
}

run_interactive() {
    check_docker

    while true; do
        show_menu
        read -r OPTION

        run_menu_option
        operation_completed
        echo ""
        read -r -p "Run another command? (y/N): " ANOTHER
        echo ""
        if [[ ! $ANOTHER =~ ^[Yy]$ ]]; then
            break
        fi
    done
}

# --- Entry point ---

if [ $# -gt 0 ]; then
    run_cli "$@"
    exit $?
fi

run_interactive

#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

DEV_COMPOSE_FILE="./docker-compose.development.yml"
TEST_COMPOSE_FILE="./docker-compose.test.yml"
TEST_ENV_FILE="./.env.test"
SERVICE_NAME="skateparks-web"
TEST_SERVICE_NAME="skateparks-web-test"
DEV_CONTAINER_NAME="rails-app"
TEST_CONTAINER_NAME="rails-app-test"

INTERACTIVE=true

check_docker() {
    if ! docker info > /dev/null 2>&1; then
        printf "${RED}Error: Docker is not running. Please start Docker first.${NC}\n"
        exit 1
    fi
}

dev_compose() {
    docker compose -f "$DEV_COMPOSE_FILE" "$@"
}

test_compose() {
    docker compose -f "$TEST_COMPOSE_FILE" --env-file "$TEST_ENV_FILE" "$@"
}

container_exists() {
    docker ps -a --format '{{.Names}}' | grep -qx "$1"
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
        if dev_compose up --remove-orphans --build --force-recreate -d; then
            echo -e "${GREEN}✅ Development server built and started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to build and start development server${NC}"
            return 1
        fi
        return 0
    fi

    if container_exists "$DEV_CONTAINER_NAME"; then
        echo -e "${GREEN}Starting development server...${NC}"
        if dev_compose start; then
            echo -e "${GREEN}✅ Development server started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to start development server${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}No existing development containers. Building and starting...${NC}"
        if dev_compose up --remove-orphans --build -d; then
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
    dev_compose logs -f "$SERVICE_NAME"
}

dev_rails_console() {
    echo -e "${GREEN}Opening Rails console...${NC}"
    dev_compose exec "$SERVICE_NAME" bundle exec rails console
}

dev_bash_shell() {
    echo -e "${GREEN}Connecting to development Docker console...${NC}"
    dev_compose exec "$SERVICE_NAME" bash
}

stop_dev_server() {
    if ! confirm_action "This will stop the development server."; then
        echo -e "${RED}Operation cancelled.${NC}"
        return 0
    fi
    echo -e "${YELLOW}Stopping development server...${NC}"
    if dev_compose stop; then
        echo -e "${GREEN}✅ Development server stopped${NC}"
    else
        echo -e "${RED}❌ Failed to stop development server${NC}"
        return 1
    fi
}

# --- Test server ---

start_test_server() {
    local rebuild="${1:-false}"

    if [ "$rebuild" = true ]; then
        if ! confirm_action "This will rebuild and recreate the test container." true; then
            echo -e "${RED}Operation cancelled.${NC}"
            return 0
        fi
        echo -e "${GREEN}Building and starting test server with fresh build...${NC}"
        if test_compose up --remove-orphans --build --force-recreate -d; then
            echo -e "${GREEN}✅ Test server built and started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to build and start test server${NC}"
            return 1
        fi
        return 0
    fi

    if container_exists "$TEST_CONTAINER_NAME"; then
        echo -e "${GREEN}Starting test server...${NC}"
        if test_compose start; then
            echo -e "${GREEN}✅ Test server started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to start test server${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}No existing test containers. Building and starting...${NC}"
        if test_compose up --remove-orphans --build -d; then
            echo -e "${GREEN}✅ Test server built and started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to build and start test server${NC}"
            return 1
        fi
    fi
}

interactive_start_test_server() {
    echo -e "${YELLOW}Rebuild from scratch? (y/N):${NC} "
    read -r -n 1 REBUILD_REPLY
    echo
    if [[ $REBUILD_REPLY =~ ^[Yy]$ ]]; then
        start_test_server true
    else
        start_test_server false
    fi
}

view_test_logs() {
    echo -e "${GREEN}Viewing test server logs...${NC}"
    test_compose logs -f "$TEST_SERVICE_NAME"
}

test_rails_console() {
    echo -e "${GREEN}Opening test Rails console...${NC}"
    test_compose exec "$TEST_SERVICE_NAME" bundle exec rails console
}

test_bash_shell() {
    echo -e "${GREEN}Connecting to test Docker console...${NC}"
    test_compose exec "$TEST_SERVICE_NAME" bash
}

stop_test_server() {
    if ! confirm_action "This will stop the test server."; then
        echo -e "${RED}Operation cancelled.${NC}"
        return 0
    fi
    echo -e "${YELLOW}Stopping test server...${NC}"
    if test_compose stop; then
        echo -e "${GREEN}✅ Test server stopped${NC}"
    else
        echo -e "${RED}❌ Failed to stop test server${NC}"
        return 1
    fi
}

# --- Tests ---

run_tests_with_coverage() {
    echo -e "${GREEN}Running tests with coverage...${NC}"
    test_compose exec "$TEST_SERVICE_NAME" bash -c "rm -rf coverage && bin/rails test"
    echo ""
    echo -e "${CYAN}Coverage report: ${NC}file://$(pwd)/coverage/index.html"
}

run_tests_fast() {
    echo -e "${GREEN}Running tests without coverage...${NC}"
    test_compose exec "$TEST_SERVICE_NAME" bash -c "DISABLE_SIMPLECOV=1 bin/rails test"
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
    test_compose exec "$TEST_SERVICE_NAME" bin/rails test "$target"
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
    if dev_compose exec "$SERVICE_NAME" bash -c "bundle exec rails db:migrate"; then
        echo -e "${GREEN}✅ Database migrated successfully${NC}"
    else
        echo -e "${RED}❌ Failed to migrate database${NC}"
        return 1
    fi
}

seed_database() {
    echo -e "${GREEN}Seeding the database...${NC}"
    if dev_compose exec "$SERVICE_NAME" bash -c "bundle exec rails db:seed"; then
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
    if dev_compose exec "$SERVICE_NAME" bash -c "bundle exec rails db:reset"; then
        echo -e "${GREEN}✅ Database reset successfully${NC}"
    else
        echo -e "${RED}❌ Failed to reset database${NC}"
        return 1
    fi
}

clear_rails_cache() {
    echo -e "${GREEN}Clearing Rails cache...${NC}"
    if dev_compose exec "$SERVICE_NAME" bash -c "bundle exec rails runner 'Rails.cache.clear'"; then
        echo -e "${GREEN}✅ Cache cleared successfully${NC}"
    else
        echo -e "${RED}❌ Failed to clear cache${NC}"
        return 1
    fi
}

reload_test_schema() {
    echo -e "${GREEN}Reloading test database schema...${NC}"
    if test_compose exec "$TEST_SERVICE_NAME" bin/rails db:schema:load; then
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
    local stopped=false
    if dev_compose stop 2>/dev/null; then
        echo -e "${GREEN}✅ Development containers stopped${NC}"
        stopped=true
    fi
    if test_compose stop 2>/dev/null; then
        echo -e "${GREEN}✅ Test containers stopped${NC}"
        stopped=true
    fi
    if [ "$stopped" = false ]; then
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
  scripts.sh lint [--fix] [--full]       Run linters (fast by default; --full adds Zeitwerk)
  scripts.sh security                  Run all security audits
  scripts.sh ci                        Run all CI parity checks in parallel
  scripts.sh dev <command>             Development server commands
  scripts.sh test-server <command>     Test server commands

Dev commands:
  up, rebuild, down, logs, console, bash, migrate, seed, reset, cache-clear

Test-server commands:
  up, rebuild, down, logs, console, bash, schema-load

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
        up) start_test_server false ;;
        rebuild) start_test_server true ;;
        down) stop_test_server ;;
        logs) view_test_logs ;;
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
        lint)
            shift
            run_linters_cli "$@"
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
    echo -e "${GREEN}--- Test Server ---${NC}"
    echo -e " ${BLUE}(6)${NC}  Start / rebuild test server"
    echo -e " ${BLUE}(7)${NC}  Run all tests (with coverage)"
    echo -e " ${BLUE}(8)${NC}  Run tests (no coverage)"
    echo -e " ${BLUE}(9)${NC}  Run single test"
    echo -e " ${BLUE}(10)${NC} View test server logs"
    echo -e " ${BLUE}(11)${NC} Rails console (test)"
    echo -e " ${BLUE}(12)${NC} Connect to test Docker console"
    echo -e " ${BLUE}(13)${NC} Stop test server"
    echo ""
    echo -e "${GREEN}--- Tests & Linting & Formatting ---${NC}"
    echo -e " ${BLUE}(14)${NC} Run linters (check, fast)"
    echo -e " ${BLUE}(15)${NC} Run all linters (fix)"
    echo -e " ${BLUE}(16)${NC} Run security audits"
    echo -e " ${BLUE}(17)${NC} Run all CI parity checks (parallel)"
    echo ""
    echo -e "${GREEN}--- Database & Cache ---${NC}"
    echo -e " ${BLUE}(18)${NC} Migrate database"
    echo -e " ${BLUE}(19)${NC} Seed the database"
    echo -e " ${BLUE}(20)${NC} Reset database"
    echo -e " ${BLUE}(21)${NC} Clear all Rails cache"
    echo -e " ${BLUE}(22)${NC} Reload test database schema"
    echo ""
    echo -e "${GREEN}--- Other ---${NC}"
    echo -e " ${BLUE}(23)${NC} Stop all skateparks Docker containers"
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
        6) interactive_start_test_server ;;
        7) run_tests_with_coverage ;;
        8) run_tests_fast ;;
        9) interactive_run_single_test ;;
        10) view_test_logs ;;
        11) test_rails_console ;;
        12) test_bash_shell ;;
        13) stop_test_server ;;
        14) run_linters_check ;;
        15) run_linters_fix ;;
        16) run_security_audits ;;
        17) run_ci_checks ;;
        18) migrate_database ;;
        19) seed_database ;;
        20) reset_database ;;
        21) clear_rails_cache ;;
        22) reload_test_schema ;;
        23) stop_all_containers ;;
        q|Q)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $OPTION${NC}"
            echo -e "${YELLOW}Please choose a valid option (1-23) or q to quit${NC}"
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

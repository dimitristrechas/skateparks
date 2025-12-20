#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

DEV_COMPOSE_FILE="./docker-compose.development.yml"
TEST_COMPOSE_FILE="./docker-compose.test.yml"
SERVICE_NAME="skateparks-web"
TEST_SERVICE_NAME="skateparks-web-test"

check_docker() {
    if ! docker info > /dev/null 2>&1; then
        printf "${RED}Error: Docker is not running. Please start Docker first.${NC}\n"
        exit 1
    fi
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
    echo -e "${YELLOW}$message${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Operation cancelled.${NC}"
        exit 0
    fi
}

clear
echo -e "${PURPLE}🛹 Skateparks.gr Development Toolkit 🛹${NC}"
echo ""

check_docker
show_docker_status

echo -e "${GREEN}--- Development Server ---${NC}"
echo -e " ${BLUE}(1)${NC}  Start development server"
echo -e " ${BLUE}(2)${NC}  Fresh build & start development server"
echo -e " ${BLUE}(3)${NC}  Attach to Docker development server"
echo -e " ${BLUE}(4)${NC}  Rails console (database queries)"
echo -e " ${BLUE}(5)${NC}  Connect to Docker console"
echo -e " ${BLUE}(6)${NC}  View development server logs"
echo -e " ${BLUE}(7)${NC}  Stop development server"
echo ""
echo -e "${GREEN}--- Test Server ---${NC}"
echo -e " ${BLUE}(8)${NC}  Start test server"
echo -e " ${BLUE}(9)${NC}  Fresh build & start test server"
echo -e " ${BLUE}(10)${NC} Connect to test Docker console"
echo -e " ${BLUE}(11)${NC} View test server logs"
echo ""
echo -e "${GREEN}--- Code Quality & Formatting ---${NC}"
echo -e " ${BLUE}(12)${NC} Run RSpec tests"
echo -e " ${BLUE}(13)${NC} Format ERB files with erb-format"
echo -e " ${BLUE}(14)${NC} Run Ruby linter (RuboCop)"
echo -e " ${BLUE}(15)${NC} Auto-fix Ruby linter issues"
echo -e " ${BLUE}(16)${NC} Format JavaScript/CSS files (Prettier)"
echo ""
echo -e "${GREEN}--- Database & Cache ---${NC}"
echo -e " ${BLUE}(17)${NC} Seed the database"
echo -e " ${BLUE}(18)${NC} Reset database & migrate"
echo -e " ${BLUE}(21)${NC} Clear all Rails cache"
echo ""
echo -e "${GREEN}--- Other ---${NC}"
echo -e " ${BLUE}(19)${NC} Stop skateparks Docker containers"
echo -e " ${BLUE}(20)${NC} Show Docker container status"
echo -e " ${BLUE}(22)${NC} Delete server PID file"
echo -e " ${BLUE}(23)${NC} Delete test server PID file"
echo ""
echo -e "${YELLOW}Choose an option:${NC} "
read OPTION

case $OPTION in

    # DEVELOPMENT SERVER OPTIONS
    1)
    echo -e "${GREEN}Starting development server...${NC}"
    if docker compose -f $DEV_COMPOSE_FILE start; then
        echo -e "${GREEN}✅ Development server started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to start development server${NC}"
        exit 1
    fi
    ;;

    2)
    confirm_action "This will rebuild and recreate the development container."
    echo -e "${GREEN}Building and starting development server with fresh build...${NC}"
    if docker compose -f $DEV_COMPOSE_FILE up --remove-orphans --build --force-recreate -d; then
        echo -e "${GREEN}✅ Development server built and started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to build and start development server${NC}"
        exit 1
    fi
    ;;

    3)
    echo -e "${GREEN}Attaching to development server...${NC}"
    docker attach $SERVICE_NAME || echo -e "${RED}❌ Failed to attach to development server${NC}"
    ;;

    4)
    echo -e "${GREEN}Opening Rails console...${NC}"
    docker compose -f $DEV_COMPOSE_FILE exec $SERVICE_NAME bundle exec rails console
    ;;

    5)
    echo -e "${GREEN}Connecting to Docker console...${NC}"
    docker compose -f $DEV_COMPOSE_FILE exec $SERVICE_NAME bash
    ;;

    6)
    echo -e "${GREEN}Viewing development server logs...${NC}"
    docker compose -f $DEV_COMPOSE_FILE logs -f $SERVICE_NAME
    ;;

    7)
    confirm_action "This will stop the development server."
    echo -e "${YELLOW}Stopping development server...${NC}"
    if docker compose -f $DEV_COMPOSE_FILE stop; then
        echo -e "${GREEN}✅ Development server stopped${NC}"
    else
        echo -e "${RED}❌ Failed to stop development server${NC}"
    fi
    ;;

    # TEST SERVER OPTIONS
    8)
    echo -e "${GREEN}Starting test server...${NC}"
    if docker compose -f $TEST_COMPOSE_FILE start; then
        echo -e "${GREEN}✅ Test server started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to start test server${NC}"
        exit 1
    fi
    ;;

    9)
    confirm_action "This will rebuild and recreate the test container."
    echo -e "${GREEN}Building and starting test server with fresh build...${NC}"
    if docker compose -f $TEST_COMPOSE_FILE --env-file ./.env.test up --remove-orphans --build --force-recreate -d; then
        echo -e "${GREEN}✅ Test server built and started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to build and start test server${NC}"
        exit 1
    fi
    ;;

    10)
    echo -e "${GREEN}Connecting to test Docker console...${NC}"
    docker compose -f $TEST_COMPOSE_FILE exec $TEST_SERVICE_NAME bash
    ;;

    11)
    echo -e "${GREEN}Viewing test server logs...${NC}"
    docker compose -f $TEST_COMPOSE_FILE logs -f $TEST_SERVICE_NAME
    ;;

    # CODE QUALITY & FORMATTING OPTIONS
    12)
    echo -e "${GREEN}Running RSpec tests with coverage...${NC}"
    docker compose -f $TEST_COMPOSE_FILE exec $TEST_SERVICE_NAME bash -c "COVERAGE=true bundle exec rspec --format progress"
    echo ""
    echo -e "${CYAN}Coverage report: ${NC}file://$(pwd)/coverage/index.html"
    ;;

    13)
    echo -e "${GREEN}Formatting ERB files...${NC}"
    if bundle exec erb-format -w app/views/**/*.erb; then
        echo -e "${GREEN}✅ ERB files formatted successfully${NC}"
    else
        echo -e "${RED}❌ Failed to format ERB files${NC}"
    fi
    ;;

    14)
    echo -e "${GREEN}Running Ruby linter (RuboCop)...${NC}"
    bundle exec rubocop
    ;;

    15)
    echo -e "${GREEN}Auto-fixing Ruby linter issues...${NC}"
    if bundle exec rubocop -A; then
        echo -e "${GREEN}✅ RuboCop auto-fixes applied successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Some issues could not be auto-fixed${NC}"
    fi
    ;;

    16)
    echo -e "${GREEN}Formatting JavaScript/CSS files with Prettier...${NC}"
    if command -v yarn >/dev/null 2>&1; then
        if yarn prettier --write .; then
            echo -e "${GREEN}✅ Files formatted with Prettier successfully${NC}"
        else
            echo -e "${RED}❌ Failed to format files with Prettier${NC}"
        fi
    else
        echo -e "${RED}❌ Yarn not found. Please install yarn first.${NC}"
    fi
    ;;

    # DATABASE & UTILITIES OPTIONS
    17)
    echo -e "${GREEN}Seeding the database...${NC}"
    if docker compose -f $DEV_COMPOSE_FILE exec $SERVICE_NAME bash -c "bundle exec rails db:seed"; then
        echo -e "${GREEN}✅ Database seeded successfully${NC}"
    else
        echo -e "${RED}❌ Failed to seed database${NC}"
    fi
    ;;

    18)
    confirm_action "This will reset and migrate the database. All data will be lost!"
    echo -e "${GREEN}Resetting and migrating database...${NC}"
    docker compose -f $DEV_COMPOSE_FILE exec $SERVICE_NAME bash -c "bundle exec rails db:reset db:migrate"
    ;;

    19)
    confirm_action "This will stop all skateparks-related Docker containers."
    echo -e "${YELLOW}Stopping skateparks Docker containers...${NC}"
    STOPPED=false
    if docker compose -f $DEV_COMPOSE_FILE stop 2>/dev/null; then
        echo -e "${GREEN}✅ Development containers stopped${NC}"
        STOPPED=true
    fi
    if docker compose -f $TEST_COMPOSE_FILE stop 2>/dev/null; then
        echo -e "${GREEN}✅ Test containers stopped${NC}"
        STOPPED=true
    fi
    if [ "$STOPPED" = false ]; then
        echo -e "${YELLOW}⚠️  No skateparks containers were running${NC}"
    fi
    ;;

    20)
    show_docker_status
    ;;

    21)
    echo -e "${GREEN}Clearing Rails cache...${NC}"
    if docker compose -f $DEV_COMPOSE_FILE exec $SERVICE_NAME bash -c "bundle exec rails runner 'Rails.cache.clear'"; then
        echo -e "${GREEN}✅ Cache cleared successfully${NC}"
    else
        echo -e "${RED}❌ Failed to clear cache${NC}"
    fi
    ;;

    # OTHER OPTIONS
    22)
    echo -e "${YELLOW}Deleting server PID file...${NC}"
    if [ -f tmp/pids/server.pid ]; then
        rm tmp/pids/server.pid
        echo -e "${GREEN}✅ Server PID file deleted${NC}"
    else
        echo -e "${YELLOW}⚠️  Server PID file not found${NC}"
    fi
    ;;

    23)
    echo -e "${YELLOW}Deleting test server PID file...${NC}"
    if [ -f tmp/pids/server_test.pid ]; then
        rm tmp/pids/server_test.pid
        echo -e "${GREEN}✅ Test server PID file deleted${NC}"
    else
        echo -e "${YELLOW}⚠️  Test server PID file not found${NC}"
    fi
    ;;

    *)
    echo -e "${RED}❌ Unknown option: $OPTION${NC}"
    echo -e "${YELLOW}Please choose a valid option (1-23)${NC}"
    exit 1
    ;;
esac

echo -e "${GREEN}Operation completed!${NC}"

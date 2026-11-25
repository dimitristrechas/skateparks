# Browser sanity checks (agent-browser on the host, against the dev server).
# Sourced by scripts.sh, which provides colors, show_help, and the repo-root working directory.

BROWSER_BASE_URL="${BROWSER_BASE_URL:-http://localhost:3002}"
BROWSER_DIR="./tmp/agent-browser"
BROWSER_ADMIN_STATE="$BROWSER_DIR/admin-state.json"
BROWSER_PUBLIC_SESSION="skateparks-public"
BROWSER_ADMIN_SESSION="skateparks-admin"
BROWSER_LOCALES="en el"
BROWSER_PUBLIC_PATHS="/ /skateparks /about /contact /privacy /session/new"
BROWSER_ADMIN_PATHS="/admin /admin/skateparks /admin/skateparks/new /admin/skateparks_popular /admin/video_suggestions /admin/users /admin/site_announcements /admin/site_announcements/new"

ensure_agent_browser() {
    if ! command -v agent-browser > /dev/null 2>&1; then
        echo -e "${RED}agent-browser not found. Install: brew install agent-browser && agent-browser install${NC}"
        return 1
    fi
    if ! curl -fsS -o /dev/null "$BROWSER_BASE_URL/healthcheck"; then
        echo -e "${RED}Dev server not reachable at $BROWSER_BASE_URL. Run: sh scripts.sh dev up${NC}"
        return 1
    fi
}

# Read a value from .env without sourcing it (values may contain shell metacharacters).
# Follows Compose rules: quoted values end at the closing quote; unquoted values drop " # comments".
dotenv_value() {
    local line value
    line=$(grep -E "^[[:space:]]*(export[[:space:]]+)?$1=" .env 2>/dev/null | tail -1)
    value="${line#*=}"
    case "$value" in
        \"*)
            value="${value#\"}"
            value="${value%%\"*}"
            ;;
        \'*)
            value="${value#\'}"
            value="${value%%\'*}"
            ;;
        *)
            value=$(printf '%s' "$value" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+#.*$//; s/[[:space:]]+$//')
            ;;
    esac
    printf '%s' "$value"
}

ab() {
    local session="$1"
    shift
    agent-browser --session "$session" "$@"
}

ab_eval() {
    ab "$1" eval "$2" 2>/dev/null | tr -d '"'
}

browser_login() {
    ensure_agent_browser || return 1
    local email password url
    email=$(dotenv_value ADMIN_EMAIL)
    password=$(dotenv_value ADMIN_PASSWORD)
    if [ -z "$email" ] || [ -z "$password" ]; then
        echo -e "${RED}ADMIN_EMAIL and ADMIN_PASSWORD must be set in .env${NC}"
        return 1
    fi

    mkdir -p "$BROWSER_DIR"
    ab "$BROWSER_ADMIN_SESSION" open "$BROWSER_BASE_URL/session/new" > /dev/null || return 1
    ab "$BROWSER_ADMIN_SESSION" fill 'input[name="email_address"]' "$email" > /dev/null || return 1
    ab "$BROWSER_ADMIN_SESSION" fill 'input[name="password"]' "$password" > /dev/null || return 1
    ab "$BROWSER_ADMIN_SESSION" click 'main form [type="submit"]' > /dev/null || return 1
    ab "$BROWSER_ADMIN_SESSION" wait --load networkidle > /dev/null
    ab "$BROWSER_ADMIN_SESSION" open "$BROWSER_BASE_URL/admin" > /dev/null || return 1

    url=$(ab "$BROWSER_ADMIN_SESSION" get url)
    case "$url" in
        */admin*) ;;
        *)
            echo -e "${RED}Admin login failed (landed on $url).${NC}"
            echo -e "${YELLOW}The .env admin is created by 'sh scripts.sh dev seed' only when no admin exists yet.${NC}"
            return 1
            ;;
    esac

    ab "$BROWSER_ADMIN_SESSION" state save "$BROWSER_ADMIN_STATE" > /dev/null
    echo -e "${GREEN}✅ Signed in as $email (session: $BROWSER_ADMIN_SESSION, state: $BROWSER_ADMIN_STATE)${NC}"
}

# Re-use the running admin session or the saved state; sign in again only when needed.
ensure_browser_admin() {
    if [ -f "$BROWSER_ADMIN_STATE" ]; then
        ab "$BROWSER_ADMIN_SESSION" --state "$BROWSER_ADMIN_STATE" open "$BROWSER_BASE_URL/admin" > /dev/null 2>&1
    else
        ab "$BROWSER_ADMIN_SESSION" open "$BROWSER_BASE_URL/admin" > /dev/null 2>&1
    fi
    case "$(ab "$BROWSER_ADMIN_SESSION" get url 2>/dev/null)" in
        */admin*) return 0 ;;
        *) browser_login ;;
    esac
}

with_locale() {
    if [ "$2" = "en" ]; then
        echo "$1"
    else
        echo "$1?locale=$2"
    fi
}

# Checks one page: HTTP status, auth redirect, JS errors, missing translations, mobile overflow.
browser_check_page() {
    local session="$1" path="$2" problems=() url final status errors
    url="$BROWSER_BASE_URL$path"

    ab "$session" errors --clear > /dev/null 2>&1
    if ! ab "$session" open "$url" > /dev/null 2>&1; then
        printf "${RED}FAIL${NC} %s — navigation failed\n" "$path"
        return 1
    fi

    final=$(ab "$session" get url 2>/dev/null)
    status=$(ab_eval "$session" "performance.getEntriesByType('navigation')[0]?.responseStatus ?? 0")
    errors=$(ab "$session" errors 2>/dev/null)

    [ "$status" = "200" ] || problems+=("HTTP $status")
    case "$final" in */session/new*) [ "${path%%\?*}" != "/session/new" ] && problems+=("redirected to sign in") ;; esac
    [ -n "$errors" ] && problems+=("JS errors: $(echo "$errors" | head -3 | tr '\n' ' ')")
    [ "$(ab_eval "$session" "document.querySelectorAll('.translation_missing').length")" = "0" ] ||
        problems+=("missing translations")
    if [ "$BROWSER_MOBILE" = true ] &&
        [ "$(ab_eval "$session" "document.documentElement.scrollWidth > window.innerWidth")" = "true" ]; then
        problems+=("horizontal overflow")
    fi

    if [ "$BROWSER_SCREENSHOTS" = true ]; then
        local name
        name=$(echo "${session}${path}" | tr '/?=' '___')
        ab "$session" screenshot "$BROWSER_DIR/screenshots/$name.png" > /dev/null 2>&1
    fi

    if [ ${#problems[@]} -eq 0 ]; then
        printf "${GREEN}ok${NC}   %s\n" "$path"
    else
        printf "${RED}FAIL${NC} %s — %s\n" "$path" "$(IFS='; '; echo "${problems[*]}")"
        return 1
    fi
}

# First href on the page matching a CSS selector, as a path.
browser_first_href() {
    local href
    href=$(ab_eval "$1" "document.querySelector('$2')?.getAttribute('href') ?? ''")
    [ "$href" = "null" ] && href=""
    echo "${href%%\?*}"
}

browser_check_paths() {
    local session="$1" paths="$2" failed=0 locale path
    for locale in $BROWSER_LOCALES; do
        echo -e "${CYAN}[$session] locale: $locale${NC}"
        for path in $paths; do
            browser_check_page "$session" "$(with_locale "$path" "$locale")" || failed=1
        done
    done
    return $failed
}

browser_smoke() {
    local scope="all" failed=0 detail
    BROWSER_MOBILE=false
    BROWSER_SCREENSHOTS=false
    while [ $# -gt 0 ]; do
        case "$1" in
            --public) scope="public" ;;
            --admin) scope="admin" ;;
            --mobile) BROWSER_MOBILE=true ;;
            --screenshots) BROWSER_SCREENSHOTS=true ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                return 1
                ;;
        esac
        shift
    done

    ensure_agent_browser || return 1
    mkdir -p "$BROWSER_DIR/screenshots"

    if [ "$BROWSER_MOBILE" = true ]; then
        ab "$BROWSER_PUBLIC_SESSION" set viewport 390 844 > /dev/null
        ab "$BROWSER_ADMIN_SESSION" set viewport 390 844 > /dev/null
    else
        ab "$BROWSER_PUBLIC_SESSION" set viewport 1280 800 > /dev/null
        ab "$BROWSER_ADMIN_SESSION" set viewport 1280 800 > /dev/null
    fi

    if [ "$scope" != "admin" ]; then
        ab "$BROWSER_PUBLIC_SESSION" open "$BROWSER_BASE_URL/skateparks" > /dev/null
        detail=$(browser_first_href "$BROWSER_PUBLIC_SESSION" 'a[href^="/skateparks/"]')
        browser_check_paths "$BROWSER_PUBLIC_SESSION" "$BROWSER_PUBLIC_PATHS $detail" || failed=1
    fi

    if [ "$scope" != "public" ]; then
        ensure_browser_admin || return 1
        ab "$BROWSER_ADMIN_SESSION" open "$BROWSER_BASE_URL/admin/skateparks" > /dev/null
        detail=$(browser_first_href "$BROWSER_ADMIN_SESSION" 'a[href^="/admin/skateparks/"][href$="/edit"]')
        browser_check_paths "$BROWSER_ADMIN_SESSION" "$BROWSER_ADMIN_PATHS $detail" || failed=1
    fi

    [ "$BROWSER_SCREENSHOTS" = true ] && echo -e "${CYAN}Screenshots: $BROWSER_DIR/screenshots${NC}"
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}✅ Browser smoke passed${NC}"
    else
        echo -e "${RED}❌ Browser smoke failed${NC}"
        return 1
    fi
}

browser_close() {
    ab "$BROWSER_PUBLIC_SESSION" close > /dev/null 2>&1
    ab "$BROWSER_ADMIN_SESSION" close > /dev/null 2>&1
    echo -e "${GREEN}✅ Browser sessions closed${NC}"
}

run_browser_cli() {
    local command="${1:-}"
    shift || true
    case "$command" in
        login) browser_login ;;
        smoke) browser_smoke "$@" ;;
        close) browser_close ;;
        *)
            echo -e "${RED}Unknown browser command: ${command}${NC}"
            show_help
            return 1
            ;;
    esac
}

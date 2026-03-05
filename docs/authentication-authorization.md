# Authentication & Authorization

Custom session-based auth. No Devise/JWT. Primitives: BCrypt + DB sessions + signed httponly cookies + `CurrentAttributes`.

---

## Data Model

```
users:      email_address, password_digest, role {user:0, admin:1}, banned_at, ban_reason
sessions:   user_id(FK), session_token(urlsafe_base64 32B), ip_address, user_agent, expires_at
audit_logs: actor_id(FK→users), target(polymorphic), action, details(jsonb)
```

**User model:**
- `has_secure_password` (BCrypt)
- `enum :role, { user: 0, admin: 1 }, default: :user`
- `normalizes :email_address` — strip + downcase on save
- Password min 12 chars (validated on `password_digest_changed?`)
- `after_update :destroy_sessions_on_role_change, if: :saved_change_to_role?`

---

## Current Model

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true
end
```

`ActiveSupport::CurrentAttributes` provides thread-safe, fiber-local storage reset automatically between requests. Two accessors:

| Accessor | Value |
|---|---|
| `Current.session` | The `Session` AR record for this request |
| `Current.user` | Delegated to `Current.session.user` (nil-safe) |

The `current_user` helper in `Authentication` concern (`Current.session&.user`) is exposed to all controllers and views via `helper_method`. Account controllers bypass the helper and read `Current.session.user` directly.

---

## Session Model

```
sessions: user_id(FK), session_token(urlsafe_base64 32B), ip_address, user_agent, expires_at
```

- Token generated via `before_validation :generate_token` (`SecureRandom.urlsafe_base64(32)`)
- `expired?` — `expires_at < Time.current`
- Scopes: `Session.expired` / `Session.active`
- `belongs_to :user`; user has `has_many :sessions, dependent: :destroy`

---

## Routes

```
resource  :session                          # POST /session (login), DELETE /session (logout)
resources :passwords, param: :token         # POST /passwords (request reset), PATCH /passwords/:token (apply)

namespace :account do
  resource :profile, only: %i[show edit update]   # /account/profile
  resource :password, only: %i[edit update]        # /account/password
end

namespace :admin do
  root → dashboard#index
  resources :users, only: %i[index show] do
    member do
      post :ban
      post :unban
    end
  end
  mount Sidekiq::Web => '/sidekiq'  # constraint: session.user.admin?
end
```

---

## Per-Request Authentication

```
GET /protected
  → before_action :require_authentication
  → resume_session
      read cookies.signed[:session_token]
      Session.find_by(session_token: token)
      check !session.expired?
      check session.user.active?
      Current.session = session
  → or redirect → /session/new  (stores return_to in Rails session)
```

`current_user` is `Current.session&.user`, exposed via `helper_method` to views and controllers.

---

## Login Flow

```
POST /session
  rate_limit: 10 req / 3 min
  → authenticate_user
      User.find_by(email_address)
      if nil: BCrypt.create(dummy) → return nil   ← timing attack mitigation
      user.authenticate(password)                 ← BCrypt compare via has_secure_password
      user.active? (!banned?)
  → start_new_session_for(user)
      sessions.create!(user_agent, ip, expires_at: 2.weeks)
      Current.session = session
      cookies.signed[:session_token] = {
        value:     session.session_token,
        httponly:  true,
        secure:    Rails.env.production?,
        same_site: :lax,
        expires:   2.weeks,
      }
  → redirect after_authentication_url
      return_to || admin_root (admins) || root
```

---

## Cookie Architecture

| Property | Value |
|---|---|
| Name | `session_token` |
| Value | HMAC-signed via Rails signed cookies (`secret_key_base`) |
| HttpOnly | true |
| SameSite | Lax |
| Secure | production only |
| Client expiry | 2 weeks |
| Server expiry | DB `expires_at` checked on every request |

---

## Logout

```
DELETE /session
  Current.session.destroy   ← removes DB row
  cookies.delete(:session_token)
```

---

## Password Reset (Unauthenticated)

```
POST /passwords
  User.find_by(email) → nil = no-op  ← prevents user enumeration
  user.signed_id(expires_in: 15min, purpose: :password_reset)
  PasswordsMailer.reset(user).deliver_later
  redirect with generic notice

PATCH /passwords/:token
  User.find_signed(token, purpose: :password_reset)  ← HMAC + expiry validation
  nil → redirect (expired or forged token)
  user.update(password, password_confirmation)
  user.sessions.destroy_all                          ← invalidate stolen sessions
  redirect → /session/new
```

The signed ID uses Rails' `GlobalID::Identification` with a message verifier scoped to `purpose: :password_reset`, so a token for one purpose cannot be reused for another.

---

## Account Management

All routes under `/account` require authentication. User reads directly from `Current.session.user`.

**Profile** (`/account/profile`) — view and update `email_address`.

**Password change** (`/account/password`):

```
PATCH /account/password
  rate_limit: 5 req / 15 min
  authenticate current_password (BCrypt compare)
  user.update(password, password_confirmation)
  user.sessions.destroy_all   ← all sessions invalidated
  cookies.delete(:session_token)
  redirect → /session/new
```

---

## WebSocket Auth (ActionCable)

```ruby
# app/channels/application_cable/connection.rb
def connect
  set_current_user || reject_unauthorized_connection
end

def set_current_user
  session = Session.find_by(session_token: cookies.signed[:session_token])
  return nil unless session
  return nil if session.expired?
  return nil unless session.user.active?
  self.current_user = session.user
end
```

ActionCable connections share the HTTP cookie jar, so the same `session_token` cookie used for HTTP requests authenticates WebSocket connections. Unauthenticated connections are rejected (not silently dropped).

---

## Admin Authorization

`Admin::BaseController` chains two `before_action`s:

1. `require_authentication` — standard session check
2. `ensure_admin` — `current_user.admin?` (role enum check), redirects to root on failure

All admin controllers inherit from `Admin::BaseController`.

Role changes trigger `sessions.destroy_all` via `after_update :destroy_sessions_on_role_change` in `User`.

**Sidekiq UI** (`/admin/sidekiq`) is protected by a route constraint that reads the session cookie directly and checks `user.admin?` — no HTTP Basic Auth.

---

## Admin User Management

`Admin::UsersController` provides user oversight at `/admin/users`.

```
GET  /admin/users          → index (all users, ordered by created_at desc)
GET  /admin/users/:id      → show (user details, sessions list, audit log last 20)
POST /admin/users/:id/ban  → ban!(reason:) + AuditLog entry
POST /admin/users/:id/unban → update(banned_at: nil) + AuditLog entry
```

Every action creates an `AuditLog` record with `actor: current_user`, `target: @user`, `action`, and optional `details` (e.g. ban reason).

---

## Banning

```ruby
def ban!(reason:)
  transaction do
    update!(banned_at: Time.current, ban_reason: reason)
    sessions.destroy_all
  end
end
```

`active?` returns `false` for banned users, so `resume_session` rejects them on the next request. The transaction ensures sessions are destroyed atomically with the ban.

---

## Admin Seeding

The first admin user is created via `db/seeds.rb` (non-production only):

```
ADMIN_EMAIL and ADMIN_PASSWORD env vars → User.create!(role: :admin)
Only runs if no admin exists.
```

Set `ADMIN_EMAIL` and `ADMIN_PASSWORD` in `.env` (see `.env.example`). The seed is idempotent and guarded by `Rails.env.production?`.

---

## Session Cleanup

Expired sessions are purged by `SessionCleanupWorker` (Sidekiq):

```ruby
def perform
  Session.expired.delete_all
end
```

Scheduled daily at 3:00 AM via `config/schedule.yml`. The `Session.expired` scope matches `expires_at < Time.current`.

---

## Security Properties

| Property | Implementation |
|---|---|
| Password storage | BCrypt via `has_secure_password` |
| Password minimum length | 12 characters (validated on digest change) |
| Timing attack mitigation | Dummy BCrypt on missing user |
| User enumeration prevention | Generic error for banned users; no-op on unknown email in reset flow |
| CSRF | Rails `protect_from_forgery` + SameSite=Lax cookie |
| Session fixation | New `Session` record created per login |
| Token entropy | `urlsafe_base64(32)` = 256 bits |
| Server-side expiry | DB `expires_at` checked on every request |
| Session invalidation | On password change/reset and ban: `sessions.destroy_all` |
| Role change invalidation | `after_update` callback destroys sessions on role change |
| WebSocket auth failure | `reject_unauthorized_connection` closes the connection |
| Sidekiq UI protection | Route constraint checks `session.user.admin?` (no HTTP Basic) |
| Audit trail | `AuditLog` records admin actions with actor, target, action, details |

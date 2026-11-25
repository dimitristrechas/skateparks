class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :audit_logs, foreign_key: :actor_id, dependent: :destroy, inverse_of: :actor

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { user: 0, admin: 1 }, default: :user

  scope :search_by_email, lambda { |query|
    sanitized = query.to_s.strip
    next all if sanitized.blank?

    where('email_address ILIKE ?', "%#{sanitize_sql_like(sanitized)}%")
  }

  validates :role, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, if: :password_digest_changed?
  validate :password_not_blank, if: :blank_password_assigned?, on: :update

  after_update :destroy_sessions_on_role_change, if: :saved_change_to_role?

  def active?
    !banned?
  end

  def banned?
    banned_at.present?
  end

  def ban!(reason:)
    transaction do
      update!(banned_at: Time.current, ban_reason: reason)
      sessions.destroy_all
    end
  end

  def password=(value)
    @blank_password_assigned = value.blank?
    super
  end

  private

  def blank_password_assigned?
    @blank_password_assigned
  end

  def password_not_blank
    errors.add(:password, :blank)
  end

  def destroy_sessions_on_role_change
    sessions.destroy_all
  end
end

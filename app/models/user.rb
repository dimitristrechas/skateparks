class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :audit_logs, foreign_key: :actor_id, dependent: :destroy, inverse_of: :actor

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { user: 0, admin: 1 }, default: :user

  validates :role, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, if: :password_digest_changed?

  after_initialize :set_default_role, if: :new_record?
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

  def generate_password_reset_token
    signed_id(expires_in: 15.minutes, purpose: :password_reset)
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def destroy_sessions_on_role_change
    sessions.destroy_all
  end
end

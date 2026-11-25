class Session < ApplicationRecord
  belongs_to :user

  before_validation :generate_token, on: :create

  validates :session_token, presence: true, uniqueness: true

  scope :expired, -> { where(expires_at: ...Time.current) }

  def self.find_active_by_token(token)
    return if token.blank?

    session = includes(:user).find_by(session_token: token)
    session if session && !session.expired? && session.user.active?
  end

  def expired?
    expires_at && expires_at < Time.current
  end

  private

  def generate_token
    self.session_token ||= SecureRandom.urlsafe_base64(32)
  end
end

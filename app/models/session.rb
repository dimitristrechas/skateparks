class Session < ApplicationRecord
  belongs_to :user

  before_validation :generate_token, on: :create

  validates :session_token, presence: true, uniqueness: true

  scope :expired, -> { where(expires_at: ...Time.current) }
  scope :active, -> { where('expires_at >= ? OR expires_at IS NULL', Time.current) }

  def expired?
    expires_at && expires_at < Time.current
  end

  private

  def generate_token
    self.session_token ||= SecureRandom.urlsafe_base64(32)
  end
end

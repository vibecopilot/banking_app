class SamlTempToken < ApplicationRecord
  belongs_to :user

  validates :token, :expires_at, presence: true

  scope :valid_tokens, -> { where('expires_at > ?', Time.current) }

  def self.generate_for(user)
    # Clean up expired tokens for this user first
    where(user: user).where('expires_at <= ?', Time.current).delete_all

    create!(
      user:       user,
      token:      SecureRandom.hex(32),
      expires_at: 2.minutes.from_now
    )
  end

  def expired?
    expires_at <= Time.current
  end
end

class User < ApplicationRecord
  has_secure_password
  
  # Roles enumeration
  enum :role, { user: 'user', admin: 'admin', editor: 'editor' }, default: 'user'
  
  # Validations
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?
  
  # Normalization
  normalizes :email_address, with: ->(email) { email.strip.downcase }
  
  # Generate JWT token
  def generate_jwt_token
    payload = {
      user_id: id,
      email: email_address,
      role: role,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, jwt_secret_key, 'HS256')
  end
  
  # Generate refresh token (longer lived)
  def generate_refresh_token
    payload = {
      user_id: id,
      type: 'refresh',
      exp: 7.days.from_now.to_i
    }
    JWT.encode(payload, jwt_secret_key, 'HS256')
  end
  
  # Decode JWT token
  def self.decode_jwt_token(token)
    decoded = JWT.decode(token, jwt_secret_key, true, { algorithm: 'HS256' })
    decoded[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
  
  # Role checks
  def admin?
    role == 'admin'
  end
  
  def editor?
    role == 'editor'
  end
  
  def user?
    role == 'user'
  end
  
  private
  
  def self.jwt_secret_key
    Rails.application.secret_key_base
  end
  
  def jwt_secret_key
    self.class.jwt_secret_key
  end
end

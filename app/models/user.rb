require 'bcrypt'

class User < ActiveRecord::Base
  attr_reader :password
  
  validates :username, :password_digest, presence: true
  validates :password, length: { minimum: 6 }, presence: true, allow_nil: true
  
  def self.find_by_credentials(username, password)
    user = User.find_by_username(username)
    return nil if user.nil?
    return user if BCrypt::Password.new(user.password_digest).is_password?(password)
  end
  
  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
    @password = password
  end
  
  def reset_session_token!
    self.session_token = SecureRandom.urlsafe_base64(16)
    self.save!
    self.session_token
  end
  
end

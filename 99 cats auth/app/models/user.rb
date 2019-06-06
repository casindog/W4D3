# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  validates :username, :session_token, uniqueness: true, presence: true
  validates :password_digest, presence: true
  # validates :password, 

  attr_reader :password

  after_initialize :ensure_session_token

  has_many :cats,
    foreign_key: :user_id,
    class_name: :Cat  

  def self.find_by_credentials(username,password)
    user = User.find_by(username: username)

    return nil if user == nil

    if user.is_password?(password)
      user
    else
      nil
    end
  end

  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64
  end

  def reset_session_token!
    self.session_token = SecureRandom.urlsafe_base64
    self.save!
    self.session_token
  end

  def password=(password)
    @password = password
    encrypted_password = BCrypt::Password.create(password)
    self.password_digest = encrypted_password
  end

  def is_password?(password)
    encrypted_password = BCrypt::Password.new(self.password_digest)
    encrypted_password.is_password?(password)
  end


end

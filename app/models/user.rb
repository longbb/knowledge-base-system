class User < ApplicationRecord
  before_save { self.email = email.downcase }
  before_save :generate_password_digest

  attr_accessor :password

  validates :name, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  validates :password, confirmation: true
  validates :status, inclusion: { in: ["active", "deleted"] }
  validates :is_expert, inclusion: { in: ["true", "false"] }
  validates_length_of :password, in: 8..20, on: :create
  validates_length_of :password, in: 8..20, allow_nil: true, on: :update

  def generate_password_digest
    if password.present?
      self.password_digest = BCrypt::Password.create(self.password, cost: 10)
    end
  end

  def authenticate password
    bcrypt = BCrypt::Password.new self.password_digest
    BCrypt::Engine.hash_secret(password, bcrypt.salt) == self.password_digest
  end
end

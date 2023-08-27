class User < ApplicationRecord
  has_secure_password
  has_many :acts, dependent: :destroy

  def attributes
    super.except("password_digest")
  end
end

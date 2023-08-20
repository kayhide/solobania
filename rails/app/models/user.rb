class User < ApplicationRecord
  has_secure_password

  def attributes
    super.except("password_digest")
  end
end

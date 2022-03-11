class User < ApplicationRecord
  devise :omniauthable

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
    end
  end

  def admin?
    role == "admin"
  end
end

class User < ApplicationRecord
  devise :omniauthable

  validates_presence_of :provider, :uid

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
    end
  end

  def admin?
    roles.include?("admin")
  end

  def method_missing(method_name, *arguments, &block)
    if method_name.to_s =~ /^(.*)_role\?$/
      roles.include?($1)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    if method_name.to_s.ends_with?("_role?")
      true
    else
      super
    end
  end
end

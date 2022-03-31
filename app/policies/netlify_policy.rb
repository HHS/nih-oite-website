class NetlifyPolicy
  attr_reader :user

  def initialize(user, _record)
    raise Pundit::NotAuthorizedError, "must be logged in" if user.nil?
    @user = user
  end

  def netlify_config?
    user.admin? || user.cms_role? || user.events_role?
  end

  def cms?
    user.admin? || user.cms_role?
  end

  def events?
    user.admin? || user.events_role?
  end
end

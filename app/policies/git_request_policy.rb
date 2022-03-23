class GitRequestPolicy < ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" if user.nil?
    super(user, record)
  end

  def gateway_settings?
    true
  end

  def git_labels?
    !record.approve_publish? || user.admin?
  end

  def git_gateway?
    true
  end
end

class ProxyController < ApplicationController
  skip_forgery_protection
  include ReverseProxy::Controller
  before_action :load_request
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def gateway_settings
    authorize @git_request
    reverse_proxy ENV["GIT_GATEWAY_HOST"], path: "settings", headers: proxy_headers
  end

  def git_labels
    authorize @git_request
    reverse_proxy ENV["GIT_GATEWAY_HOST"], path: original_path, headers: proxy_headers
  rescue Pundit::NotAuthorizedError
    render json: {message: "Only administrators can approve posts for publishing"}, status: :forbidden
  end

  def git_gateway
    authorize @git_request
    reverse_proxy ENV["GIT_GATEWAY_HOST"], path: original_path, headers: proxy_headers
  end

  private

  def original_path
    request.env["ORIGINAL_FULLPATH"].gsub(/^.*(github)/, '\1')
  end

  def proxy_headers
    {Authorization: request.headers["Authorization"]}
  end

  def load_request
    @git_request = GitRequest.new params
  end

  def user_not_authorized
    render json: {message: "You are not authorized to perform this action"}, status: :unauthorized
  end
end

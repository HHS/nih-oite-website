class ProxyController < ApplicationController
  skip_forgery_protection
  include ReverseProxy::Controller

  def token
    if user_signed_in?
      render json: {
        access_token: jwt_token
      }
    else
      redirect_to root_path
    end
  end

  def user
    if user_signed_in?
      render json: {
        email: current_user.email,
        user_metadata: {
          avatar_url: "https://avatars.githubusercontent.com/u/285842"
        }
      }
    else
      redirect_to root_path
    end
  end

  def git_gateway
    unless user_signed_in?
      head :unauthorized
      return
    end
    path = if params[:path].match?(/github/)
      request.env["ORIGINAL_FULLPATH"].gsub(/^.*(github)/, '\1')
    else
      params[:path]
    end
    reverse_proxy ENV["GIT_GATEWAY_HOST"], path: path, headers: {Authorization: request.headers["Authorization"]}
  end

  private def jwt_token
    payload = {
      email: current_user.email,
      app_metadata: {
        roles: ["cms"]
      },
      user_metadata: {}
    }
    JWT.encode payload, Rails.application.credentials.jwt_secret
  end
end

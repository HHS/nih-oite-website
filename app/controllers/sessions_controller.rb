class SessionsController < ::Devise::SessionsController
  skip_forgery_protection

  def token
    if user_signed_in?
      render json: {
        access_token: jwt_token
      }
    else
      render json: {message: "User must be logged in first"}, status: :unauthorized
    end
  end

  def user
    if user_signed_in?
      render json: user_json
    else
      render json: {message: "User must be logged in first"}, status: :unauthorized
    end
  end

  private

  def user_json
    {
      email: current_user.email,
      user_metadata: {
        avatar_url: "https://avatars.githubusercontent.com/u/285842"
      }
    }
  end

  def jwt_token
    payload = user_json.merge exp: 5.minutes.from_now.to_i, app_metadata: {roles: [current_user.role]}
    JWT.encode payload, Rails.application.credentials.jwt_secret
  end
end

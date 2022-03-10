class SessionsController < ::Devise::OmniauthCallbacksController
  skip_forgery_protection

  def github
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Github") if is_navigational_format?
    else
      session["devise.github_data"] = auth.except(:extra)
      redirect_to root_path
    end
  end

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
      render json: user_json
    else
      redirect_to root_path
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
    payload = user_json.merge app_metadata: {roles: [current_user.role]}
    JWT.encode payload, Rails.application.credentials.jwt_secret
  end
end

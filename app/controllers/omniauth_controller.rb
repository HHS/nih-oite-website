class OmniauthController < ::Devise::OmniauthCallbacksController
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
end

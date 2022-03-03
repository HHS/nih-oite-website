class SessionsController < ::Devise::OmniauthCallbacksController
  skip_forgery_protection only: :github

  def github
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      session["token"] = auth.credentials.token
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Github") if is_navigational_format?
    else
      session["devise.github_data"] = auth.except(:extra)
      redirect_to root_path
    end
  end

  def netlify
    if user_signed_in?
      render inline: <<~SCRIPT
        <script>
          (function() {
            function receiveMessage(e) {
              window.opener.postMessage(
                'authorization:github:success:{"token": "#{session["token"]}", "provider": "github"}',
                e.origin
              )
            }
            window.addEventListener("message", receiveMessage, false)
            // Start handshare with parent
            window.opener.postMessage("authorizing:github", "*")
          })()
        </script>
      SCRIPT
    else
      store_location_for(:user, netlify_auth_path)
      render layout: false
    end
  end
end

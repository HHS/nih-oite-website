require_relative "./production"

Rails.application.configure do
  config.action_mailer.default_url_options = {host: "nih_oite_experiments-staging.app.cloud.gov"}

  # insert any staging overrides here
  config.x.show_demo_banner = true
end

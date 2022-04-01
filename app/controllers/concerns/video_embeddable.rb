module VideoEmbeddable
  extend ActiveSupport::Concern

  included do
    content_security_policy do |policy|
      policy.frame_src "https://www.youtube-nocookie.com"
    end
  end
end

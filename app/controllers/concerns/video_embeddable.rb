module VideoEmbeddable
  extend ActiveSupport::Concern

  included do
    content_security_policy do |policy|
      policy.frame_src "https://www.youtube-nocookie.com", "https://videocast.nih.gov"
    end
  end
end

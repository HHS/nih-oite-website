class ProxyController < ApplicationController
  skip_forgery_protection
  include ReverseProxy::Controller

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
end

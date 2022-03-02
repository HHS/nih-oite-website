class PagesController < ApplicationController
  def home
  end

  def netlify
    render layout: false
  end
end

require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "sessions"}
  devise_scope :user do
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end

  scope ".netlify" do
    match "git/*path" => "proxy#git_gateway", :via => :all
    scope "identity" do
      post "token" => "proxy#token"
      get "user" => "proxy#user"
    end
  end

  get "admin/config", format: "yml", to: "pages#netlify_config"
  get "admin/", to: "pages#netlify"

  root "pages#home"

  get "*path", to: "pages#page"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end

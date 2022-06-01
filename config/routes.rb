require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "omniauth"}
  devise_scope :user do
    delete "sign_out", to: "sessions#destroy", as: :destroy_user_session
  end

  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end

  scope ".netlify" do
    scope "git" do
      get "settings" => "proxy#gateway_settings"
      scope "github" do
        put "issues/:id/labels" => "proxy#git_labels"
        post "git/trees" => "proxy#create_tree"
        match "*path" => "proxy#git_gateway", :via => :all
      end
    end
    devise_scope :user do
      scope "identity" do
        post "token" => "sessions#token"
        get "user" => "sessions#user"
      end
    end
  end

  get "admin/config", format: "yml", to: "pages#netlify_config"
  get "admin/", to: "pages#netlify"

  resources :events, only: %i[index show], constraints: {id: /\d{6,8}-.*/}

  get "events/*path", to: "pages#page", defaults: {path_prefix: "events/"}

  get "sitemap", to: "pages#sitemap"
  get "robots", to: "pages#robots"

  root "pages#page", defaults: {path: "home"}

  get "home", to: redirect("/")

  get "*path", to: "pages#page", as: :content_page

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  devise_for :users
  namespace :v1 do
    jsonapi_resources :articles

    jsonapi_resources :gridware

    jsonapi_resources :customizers

    jsonapi_resources :users
  end
end

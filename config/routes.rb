Rails.application.routes.draw do
  namespace :v1 do
    jsonapi_resources :articles

    jsonapi_resources :gridware_packages

    jsonapi_resources :users
  end
end

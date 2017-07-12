Rails.application.routes.draw do
  namespace :v1 do
    jsonapi_resources :articles

    jsonapi_resources :gridware

    jsonapi_resources :users
  end
end

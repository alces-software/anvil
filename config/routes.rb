Rails.application.routes.draw do
  namespace :v1 do
    jsonapi_resources :articles

    jsonapi_resources :collections

    jsonapi_resources :customizers

    jsonapi_resources :gridware

    jsonapi_resources :users

    get 'search', to: 'search#search'
  end
end

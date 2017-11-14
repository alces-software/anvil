Rails.application.routes.draw do
  namespace :v1 do
    jsonapi_resources :articles

    jsonapi_resources :collections

    jsonapi_resources :packages

    jsonapi_resources :users

    get 'search', to: 'search#search'
  end
end

Rails.application.routes.draw do
  namespace :v1 do
    jsonapi_resources :articles

    jsonapi_resources :categories

    jsonapi_resources :collections

    jsonapi_resources :packages

    jsonapi_resources :users

    jsonapi_resources :sites
    jsonapi_resources :documents

    get 'search', to: 'search#search'
    post 'upload', to: 'upload#upload'
  end
end

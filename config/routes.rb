Rails.application.routes.draw do
  devise_for :users,
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations',
                 confirmations: 'users/confirmations',
                 passwords: 'users/passwords',
                 #omniauth_callbacks: 'users/omniauth_callbacks'
             },
             path_names: {sign_in: 'sign-in', sign_out: 'sign-out', sign_up: 'sign-up', password: 'reset-password'},
             only: [:sessions, :registrations, :confirmations],#, :omniauth_callbacks],
             skip_helpers: true,
             format: false

  devise_scope :user do
    post   'sign-in'                 => 'users/sessions#create',      format: false
    delete 'sign-out'                => 'users/sessions#destroy',     format: false
    post   'sign-up'                 => 'users/registrations#create', format: false
#    post   'sign-up-oauth'           => 'users/registrations#create_from_oauth', format: false
    post   'request-password-reset'  => 'users/passwords#create',     format: false
    put    'reset-password'          => 'users/passwords#update',     format: false#, as: :account_password
  end

  namespace :v1 do
    jsonapi_resources :articles

    jsonapi_resources :gridware

    jsonapi_resources :customizers

    jsonapi_resources :users

    get 'search', to: 'search#search'
  end
end

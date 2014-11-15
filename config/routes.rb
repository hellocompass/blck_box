BlackIn::Application.routes.draw do
  mount Peek::Railtie => '/peek'
  root to: 'pages#index'

  namespace :api do
    scope 'app' do
      get 'bootstrap' => 'app#bootstrap', as: 'bootstrap'
    end

    resources :groups, only: [:show, :create, :update]
    scope 'groups' do
      get ':group_id/recent' => 'contents#recent', as: 'recent_contents'
    end

    resources :sessions, only: [:new, :create, :destroy]
    get 'signin' => 'sessions#new', as: 'signin'
    get 'signout' => 'sessions#destroy', as: 'signout'

    resources :users, only: [:new, :create, :show]
    get 'signup' => 'users#new'
    get 'reset_password' => 'users#reset_password'
  end

  get '/signin' => 'sessions#new'

  get '/auth/:provider/callback' => 'api/sessions#create_with_omniauth'
  get '/auth/failure' => 'api/sessions#auth_failure'

  get '/test_github' => 'pages#test_github'
end

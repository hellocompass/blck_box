BlackIn::Application.routes.draw do
  mount Peek::Railtie => '/peek'
  root to: 'pages#index'

  namespace :api do 
    resources :users, only: [:new, :create, :show, :update]
    get 'signup' => 'users#new'
    get 'reset_password' => 'users#reset_password'

    resources :sessions, only: [:new, :create, :destroy]
    get 'signin' => 'sessions#new', as: 'signin'
    get 'signout' => 'sessions#destroy', as: 'signout'

    resources :groups, only: [:show, :create, :update]
    scope 'groups' do
      get ':group_id/recent' => 'contents#recent', as: 'recent_contents'
    end
  end

  get '/signin' => 'sessions#new'
  
  get '/auth/:provider/callback' => 'api/sessions#create_with_omniauth'
  get '/auth/failure' => 'api/sessions#auth_failure'

  get '/test_github' => 'pages#test_github'
end

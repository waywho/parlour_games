Rails.application.routes.draw do
  get 'users/new'
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount ActionCable.server => '/cable'

  namespace :api, defaults: {format: 'json'} do
    resources :messages
    resources :chatrooms do
      post 'join_chat', defaults: {format: :json}
      post 'leave_chat', defaults: {format: :json}
      # collection do
      #   get 'start_chat', defaults: {format: :json}
      # end
    end
    resources :games do
      # post 'setup', on: :member
    end
    resources :game_sessions
    resources :users do
      get 'confirmation'
    end
    post 'user_token' => 'user_token#create'
    post 'user_confirmation' => 'users#confirmation'
  end
  
  root 'landings#index'
  get 'signup', to: 'users#new'
  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'
  get '/*path', to: 'landings#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

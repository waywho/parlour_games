Rails.application.routes.draw do
  # Serve websocket cable requests in-process
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
    resources :users
    post 'user_token' => 'user_token#create'
  end
  
  root 'landings#index'
  get '/*path', to: 'landings#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
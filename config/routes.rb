Rails.application.routes.draw do
  resources :users
  get 'landings/index'
  root 'landings#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

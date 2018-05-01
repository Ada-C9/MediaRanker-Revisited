Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'works#root'
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'

  get "/auth/:provider/callback", to: "sessions#create", as: 'auth_callback'

  resources :works
  post '/works/:id/upvote', to: 'works#upvote', as: 'upvote'

  resources :users, only: [:index, :show]

  delete "/logout", to: "sessions#destroy", as: "logout"
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'works#root'
  get '/auth/github', as: 'github_login'
  get '/auth/:provider/callback', to: 'sessions#create', as: 'auth_callback'

  get '/login', to: 'sessions#login_form', as: 'login'
  post '/login', to: 'sessions#login'

  delete "/logout", to: "sessions#destroy", as: "logout"


  resources :works
  post '/works/:id/upvote', to: 'works#upvote', as: 'upvote'

  resources :users, only: [:index, :show]
end

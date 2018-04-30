Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'works#root'


  get '/auth/:provider/callback', as: 'auth_callback', to: 'sessions#create'
  get '/auth/github', as: 'github_login'
  delete '/logout', to: 'sessions#destroy', as: "logout"


  resources :works
  post '/works/:id/upvote', to: 'works#upvote', as: 'upvote'

  resources :users, only: [:index, :show, :create]
end

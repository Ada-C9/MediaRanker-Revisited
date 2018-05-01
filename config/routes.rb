Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'works#root'

  get '/auth/github', as: 'github_login'
  # get '/login', to: 'sessions#login_form', as: 'login'
  # # post '/login', to: 'sessions#login'
  post '/logout', to: 'sessions#logout', as: 'logout'

  resources :works
  post '/works/:id/upvote', to: 'works#upvote', as: 'upvote'

  resources :users, only: [:index, :show]

  get "/auth/:provider/callback", to: "sessions#create", as: 'auth_callback'
end
# Prefix Verb   URI Pattern                        Controller#Action
#      root GET    /                                  works#root
#     login GET    /login(.:format)                   sessions#login_form
#    logout POST   /logout(.:format)                  sessions#logout
#     works GET    /works(.:format)                   works#index
#           POST   /works(.:format)                   works#create
#  new_work GET    /works/new(.:format)               works#new
# edit_work GET    /works/:id/edit(.:format)          works#edit
#      work GET    /works/:id(.:format)               works#show
#           PATCH  /works/:id(.:format)               works#update
#           PUT    /works/:id(.:format)               works#update
#           DELETE /works/:id(.:format)               works#destroy
#    upvote POST   /works/:id/upvote(.:format)        works#upvote
#     users GET    /users(.:format)                   users#index
#      user GET    /users/:id(.:format)               users#show
#           GET    /auth/:provider/callback(.:format) sessions#login

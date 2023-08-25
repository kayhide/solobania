Rails.application.routes.draw do
  namespace :api do
    resource :auth, only: %i(show create), controller: :auth
    resources :specs, only: %i(index)
  end
end

Rails.application.routes.draw do
  namespace :api do
    resource :auth, only: %i(show create), controller: :auth
    resources :specs, only: %i(index), shallow: true do
      resources :packs, only: %i(index show create)
    end
  end
end

Rails.application.routes.draw do
  namespace :api do
    resource :auth, only: %i(show create), controller: :auth
  end
end

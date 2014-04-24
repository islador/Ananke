Ananke::Application.routes.draw do

  get "whitelist/white_list"
  get "whitelist/white_list_log"
  get "whitelist/retrieve_pullable_apis", to: "whitelist#retrieve_pullable_apis"

  resources :whitelist,  only: [:create, :destroy]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users

  resources :users do
    resources :api do
      get "/character_list", to: "api#character_list"
      put "/set_main", to: "api#set_main"
      put "/cancel_whitelist_api_pull", to: "api#cancel_whitelist_api_pull"
      put "/begin_whitelist_api_pull", to: "api#begin_whitelist_api_pull"
      put "/update_api_whitelist_standing", to: "api#update_api_whitelist_standing"
    end
  end
  
  #Set root to the sign_in page.
  #http://stackoverflow.com/questions/4954876/setting-devise-login-to-be-root-page
  devise_scope :user do
    root to: "devise/sessions#new"
  end

  #root to: 'static_pages#home'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

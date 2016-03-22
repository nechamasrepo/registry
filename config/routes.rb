Rails.application.routes.draw do
  # User Routes (including all neccesary for the devise options (:confirmable etc.) in the User model)
  devise_for :users
  # Item Routes (index, show, new, edit, create, update, destroy)
  resources :items
  # Home Page  
  root to: 'public#landing'
  # Routes for created views  
  get 'items/:id/gotit', to: 'items#got_it', as: :got_it
  get 'fulfillments', to: 'fulfillments#index', as: :fulfillments
  # Routes for created methods  
  post 'fulfillments/create', to: 'fulfillments#create'
  post 'fulfillments/usercreate', to: 'fulfillments#user_create', as: :fulfillments_user_create
  patch 'fulfillments/:id/fulfill', to: 'fulfillments#mark_seen', as: :fulfill
  patch 'fulfillments/:id/spam', to: 'fulfillments#mark_spam', as: :spam
  get 'search', to: 'public#search_results', as: :search
  get 'scrape', to: 'public#scrape', as: :scrape
  get 'new_user_registration_collect_email', to: 'public#new_user_registration_collect_email', as: :new_user_registration_collect_email
  
  
  # Last Route:
  get '/:link_id', to: 'items#index', as: :user_registry
  
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

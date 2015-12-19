Rails.application.routes.draw do
  devise_for :org_people, :controllers => { 
    :registrations => "org_people/registrations",
    :sessions => "org_people/sessions",
    :passwords => "org_people/passwords" , 
    :confirmations => "org_people/confirmations" }
  devise_scope :org_person do 
    get 'signup',  to: 'org_people/registrations#new'
    get 'signin',  to: 'org_people/sessions#new'
    delete 'signout', to: 'org_people/sessions#destroy'
  end


  post 'carts/add/' => 'carts#add', :to => 'carts_add'

  get 'org_companies/:id/company_profile' => 'org_companies#company_profile', :as => 'org_companies_company_profile'
  get 'org_companies/people/' => 'org_companies#people', :to => "org_companies_people"
  
  get 'org_people/stripe_settings/' => 'org_people#stripe_settings', :to => "org_people_stripe_settings"
  post 'org_people/stripe_update_settings/' => 'org_people#stripe_update_settings', :to => "org_people_stripe_update_settings"
  post 'org_people/edit_position/' => 'org_people#edit_position', :to => "org_people_edit_position"
  post 'org_people/remove_from_company/' => 'org_people#remove_from_company', :to => "org_people_remove_from_company"

  post 'org_products/vote_product/' => 'org_products#vote_product', :to => "org_products_vote_product"

  post 'trx_orders/stripe/' => 'trx_orders#stripe', :to =>"trx_orders_stripe"

  # - Stripe routes
  # - Create accounts
  post '/connect/managed' => 'stripe#managed', as: 'stripe_managed'
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

  resources :carts
  resources :catalogues
  resources :org_people
  resources :org_companies
  resources :org_products
  resources :trx_orders
  root "catalogues#index"

  match '/org_register', to:'org_companies#new', via: 'get'

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

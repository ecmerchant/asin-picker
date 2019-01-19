Rails.application.routes.draw do

  root to: 'products#search'
  get 'products/search'
  post 'products/update', to: 'products#update', as: 'products_update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

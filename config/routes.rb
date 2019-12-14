Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'
  
  resources :candidates do
    get :add_experience, on: :collection
    get :gen_card,       on: :collection
  end

  resources :companies do
    get :new_contract,     on: :member
    post :create_contract, on: :member
  end

  resources :contracts

  resources :projects

  resources :location_data
end

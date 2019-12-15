Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'home#index'
  
  resources :candidates do
    get :add_experience, on: :collection
    get :gen_card,       on: :collection

    post :create_seat,   on: :collection
    get :edit_seat,      on: :member
    put :update_seat,    on: :member
  end

  resources :companies do
    get :new_contract,     on: :member
    get :new_seat,         on: :member
  end

  resources :contracts

  resources :projects

  resources :location_data
end

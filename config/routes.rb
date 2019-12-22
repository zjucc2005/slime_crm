# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resources :users do
    post :admin_create,      on: :collection  # create users by admin
    get :edit_password,      on: :member
    put :edit_password,      on: :member

    get :my_account,         on: :collection
    get :edit_my_account,    on: :collection
    put :edit_my_account,    on: :collection
    get :edit_my_password,   on: :collection
    put :edit_my_password,   on: :collection
  end
  
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

  resources :location_data do
    get :autocomplete_city, on: :collection
  end
end

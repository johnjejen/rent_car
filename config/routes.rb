Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users
  root :to => "index#index"

  namespace :cars do

    get :new
    post :create_car
    get :index
    get :view_car_id
    post :reserve_car
    get :my_rent
    post :cancel_reserve
    post :review
    get :my_car
    get :edit_car_id

  end
  get "cars/view_car/:id" => 'cars#view_car'
  get "cars/edit_car/:id" => 'cars#edit_car'

end

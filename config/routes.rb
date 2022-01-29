Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users, only: [:edit, :update] do
    collection do
      get :mypage
      get :confirm
    end
  end

  # homes_controller
  root to: 'homes#top'
  get 'inqury', to: 'homes#inqury', as: 'inqury'

  resources :courts, only: [:index, :new, :create] do
    member do
      get :detail
    end
    collection do
      get :address
      get :map_check
      get :confirm
      get :thanks
      get :map_search
    end
  end

  resources :events do
    collection do
      get :confirm
      get :address
      get :court_select
    end
  end

  resources :court_reviews, only: [:index, :new, :edit, :update]

  resources :court_histories, only: [:index]

  resources :event_histories, only: [:index]

  resources :court_favorites, only: [:index, :create, :destroy]

  resources :event_favorites, only: [:index, :create, :destroy]
end

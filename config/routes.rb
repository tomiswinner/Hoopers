Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users, only: [:edit, :update] do
    collection do
      get :mypage
      get :confirm
      get :events
    end
  end

  # homes_controller
  root to: 'homes#top'
  get 'inqury', to: 'homes#inqury', as: 'inqury'

  resources :courts, only: [:index, :new, :create, :show] do
    resources :court_reviews, only: [:index, :new, :edit, :update, :create]
    collection do
      get :address
      get :map_check
      post :confirm
      get :thanks
      get :map_search
    end
  end

  resources :court_infos

  resources :events do
    collection do
      post :confirm
      get :address
      get :court_select
    end
  end


  resources :court_histories, only: [:index]

  resources :event_histories, only: [:index]

  resources :court_favorites, only: [:index, :create, :destroy]

  resources :event_favorites, only: [:index, :create, :destroy]
end

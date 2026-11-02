Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  resource :profile, only: [:show], controller: "users/profiles"
  root "products#index"

  # Каталог товарів та відгуки
  resources :products, only: [:index, :show] do
    resources :reviews, only: [:create, :update, :destroy]
  end

  # Кошик
  resource :cart, only: [:show, :destroy]

  resources :cart_items, only: [:create, :update, :destroy]

  # Замовлення
  resources :orders, only: [:index, :new, :create, :show] do
    member do
      patch :cancel
    end
  end

  # Контактна форма
  resources :contact_messages, only: [:new, :create]

  # Адміністративна панель
  namespace :admin do
    root "dashboard#index"
    resources :categories, except: [:show]
    resources :products, except: [:show]
    resources :orders, only: [:index, :show, :update]
    resources :contact_messages, only: [:index, :show, :update, :destroy]
  end
end
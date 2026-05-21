Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Autenticação
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Dashboard
  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  # Recursos
  resources :clientes do
    collection do
      post :undo_destroy
    end
    resources :mesas, controller: "mesas_de_bilhar", except: [ :index, :show ] do
      collection do
        post :undo_destroy
      end
    end
  end
  resources :manutencao, path: "manutencao" do
    collection do
      post :undo_destroy
    end
    resources :itens, controller: "itens_manutencao", except: [ :index, :show ] do
      collection do
        post :undo_destroy
      end
    end
  end
  resources :estoque, path: "estoque" do
    member do
      patch :ajustar_quantidade
    end
    collection do
      post :undo_destroy
    end
  end
  resources :financeiro, path: "financeiro" do
    collection do
      post :undo_destroy
    end
  end
end

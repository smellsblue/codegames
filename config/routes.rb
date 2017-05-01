# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "games#index"

  resources :games, only: %i[index create show] do
    collection do
      post :join
      post :leave
    end

    member do
      get :ended
    end
  end
end

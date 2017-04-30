# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "games#new"

  resources :games, only: [:new, :create] do
    collection do
      post :join
    end
  end
end

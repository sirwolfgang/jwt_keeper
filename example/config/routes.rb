Rails.application.routes.draw do
  resource :sessions, only: [:create, :update, :destroy]
end

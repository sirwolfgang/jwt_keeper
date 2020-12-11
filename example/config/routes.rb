# frozen_string_literal: true

Rails.application.routes.draw do
  resource :session, only: [:show, :create, :update, :destroy]
end

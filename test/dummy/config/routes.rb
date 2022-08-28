# frozen_string_literal: true

Rails.application.routes.draw do
  mount ApiBase::Engine => '/api_base'
end

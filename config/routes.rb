Rails.application.routes.draw do
  root 'status_history#index'

  controller 'status_history' do
    get 'sessions_status_by_date'
    get 'sessions_time_by_date'
    get 'broken_tests'
  end

  resources :webhook, only: :create
end

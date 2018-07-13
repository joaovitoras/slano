Rails.application.routes.draw do
  root 'status_history#index'

  controller 'status_history' do
    get 'sessions_status_by_date'
    get 'broken_tests'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

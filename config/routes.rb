Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  # Defines the root path route ("/")
  root "products#index"
  get "get_csv" => "products#get_csv"
  get 'products/:filename', to: 'products#show', as: :download
  get 'csv_status/:job_id', to: 'products#csv_status'

end

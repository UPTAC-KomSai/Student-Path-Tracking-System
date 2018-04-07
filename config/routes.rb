Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'records#index'  
  resources :records 
   
  post '/dashboard' => 'records#home' 
  get '/dashboard' => 'records#home' 

end

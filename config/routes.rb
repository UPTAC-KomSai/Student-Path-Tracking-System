Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'records#index'
  resources :records
  
  get '/student_login' => 'records#student_login'
  get '/faculty_login' => 'records#faculty_login'

  post '/dashboard' => 'records#home'
  get '/dashboard' => 'records#home'
  
  post '/personalProfile' => 'records#personalProfile'
  get '/personalProfile' => 'records#personalProfile'
  
  post '/charts' => 'records#charts'
  get '/charts' => 'records#charts'
  
  post '/grades' => 'records#grades'
  get '/grades' => 'records#grades'
  
  post '/grades/incurred5' => 'records#incurred5'
  get '/grades/incurred5' => 'records#incurred5'
  
  post '/schedule' => 'records#schedule'
  get '/schedule' => 'records#schedule'
  
  post '/studyplan' => 'records#studyplan'
  get '/studyplan' => 'records#studyplan'
end

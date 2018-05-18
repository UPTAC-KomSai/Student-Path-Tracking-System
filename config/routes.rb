Rails.application.routes.draw do
  get 'spts/index'
  get 'spts/about', :to => 'spts#about'
  get 'spts/developers_portal', :to => 'spts#developers_portal'
  post 'spts/student_login', :to => 'spts#student_login'
  post 'spts/faculty_login', :to => 'spts#faculty_login'
  delete 'spts/logout', :to => 'spts#logout'
  root 'spts#index'

  get 'student/dashboard', :to => 'students#dashboard'
  get 'student/charts', :to => 'students#charts'
  get 'student/grades', :to => 'students#grades'

  resources :study_paths
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
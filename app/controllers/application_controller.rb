class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :except => [:index, :student_login, :faculty_login]
  protect_from_forgery with: :exception

  protected
    def authenticate_user!
      if session[:user].nil?
        redirect_to '/'
      end
    end
end

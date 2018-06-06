class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :except => [:index, :student_login, :faculty_login]
  protect_from_forgery with: :exception

  protected
    def authenticate_user!
      if session[:user].nil?
        redirect_to '/'
      end
    end

  private
    def access_crs
      @student = Student.new session[:user]['id'], session[:user]['password']
      @student.login
      @basic_info = @student.basic_info
      @study_path = StudyPath.where(degree_id: "#{@basic_info['degree_program']}").take

      if @study_path.nil?
      	@study_path = StudyPath.new
      	@study_path.id = 0
      end
    end
end

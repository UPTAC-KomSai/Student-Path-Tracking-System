require 'student'

class StudentsController < ApplicationController
  before_action :access_crs

  def dashboard
    @title = 'SPTS - Dashboard'
    @current_schedule = @student.current_schedule
  end

  def charts
  end

  def grades
    @myGrades = @student.grades
  end

  private
    def access_crs
      @student = Student.new session[:user]['id'], session[:user]['password']
      @student.login
      @basic_info = @student.basic_info
    end
end

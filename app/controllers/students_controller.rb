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

    my_units = Array.new 
    @myGrades.each do |content|
       my_units << content[(content.length - 1)][:subj]
       content[0][:subj].tr!('()', '')
       
       my_units.each do |unit|
          content[(content.length - 1)][:subj] =  unit[0, unit.index("Class")]
          content[(content.length - 1)][:units] =  " " + unit[unit.index("Class"), unit.index("GWA") - unit.index("Class")]
          content[(content.length - 1)][:finalGrade] = " "+ unit[unit.index("GWA"), unit.length - unit.index("GWA") -1]
      end
    end
  end
end

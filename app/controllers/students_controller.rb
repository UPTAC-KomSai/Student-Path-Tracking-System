require 'student'

class StudentsController < ApplicationController
  before_action :access_crs

  def dashboard
    @title = 'SPTS - Dashboard'
    @current_schedule = @student.current_schedule
  end

  def charts
    @title = 'SPTS - Charts'
  end

  def grades
    @myGrades = @student.grades
    
    if !params.nil?
      @myGrades.each do |content|
        content.each do |row|
          if row.has_key? :finalGrade or row.has_key? :completionGrade
            if params["highlight"].eql? '5s'
              if row[:finalGrade].eql? ' 5.0 ' or row[:completionGrade].eql? ' 5.0 '
                row[:class] = 'table-danger'
              else
                row[:class] = 'x'
              end
            else
              if row[:finalGrade].eql? ' INC '
                row[:class] = 'table-warning'
              else
                row[:class] = 'x'
              end
            end
          end
        end
      end
    end

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

    @title = 'SPTS - Grades'
  end
end

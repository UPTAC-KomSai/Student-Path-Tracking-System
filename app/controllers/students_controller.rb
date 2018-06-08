require 'student'

class StudentsController < ApplicationController
  before_action :access_crs

  def dashboard
    @current_schedule = @student.current_schedule

    @title = "SPTS - Dashboard"
  end

  def charts
    @myGrades = @student.grades

    my_units = Array.new 
    @gwa = ""
    @labels = ""
    @myGrades.each_with_index do |content, i|
      if content[0][:subj].include? "Midyear"
        if i == @myGrades.length - 1
          @labels = @labels[0, @labels.length-2]
        end

        next
      end

      if i == @myGrades.length-1
        @labels << content[0][:subj]
      else
        @labels << content[0][:subj]+ "~"
      end
      my_units << content[(content.length - 1)][:finalGrade]
    end
    
    my_units.each_with_index do |unit, i|
      if i == my_units.length-1
        @gwa << unit[(unit.index("GWA")+4), (unit.length - unit.index("GWA")+2)] 
      else
        @gwa << unit[(unit.index("GWA")+4), (unit.length - unit.index("GWA")+2)]+ ","
      end
    end

    @title = 'SPTS - Charts'
  end

  def grades
    @myGrades = @student.grades
    
    if !params.nil? and params.has_key? "highlight"
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

    @title = 'SPTS - Grades'
  end

  def unitsEarned
    @total_units = @student.units_earned

    @title = 'SPTS - Units Earned'
  end
  
  def unitsToGo
    @myGrades = @student.grades

    my_units = Array.new
    
    @myGrades.each do |content|
       my_units << content[(content.length - 1)][:subj]
    end
    
    @total_units = 0;
    my_units.each do |unit|
      @total_units = @total_units + unit[32, 4].to_i
    end

    @title = 'SPTS - Units To Go'
  end
end

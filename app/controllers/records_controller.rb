class RecordsController < ApplicationController
  def index 
  end

  def home
    a = Mechanize.new
    stud_id = params[:student_number]
    password = params[:password]  	
    String url = 'http://crs.upv.edu.ph/tacloban/student/loginAuthenticate.jsp?studentIDYear=&studentIDNumber='+stud_id+'&password='+password
        
    login = a.get(url)
    
    if(login.uri.to_s.include?("errorMsg"))
      redirect_to action: "index"
    end
  end
  
  def personalProfile
  end
  
  def charts
  end
  
  def grades
  end
  
  def schedule
  end
  
  def studyplan
  end
  
  def incurred5
  end
end

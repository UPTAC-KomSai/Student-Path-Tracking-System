class RecordsController < ApplicationController

  @stud_info
  @@id 
  @@pw 

  def index 
  end

  def student_login    
  end

  def faculty_login
  end

  def home
      a = Mechanize.new
    
      stud_id  = params[:student_number]
      password = params[:password] 
      
      if stud_id != nil and password != nil
         @@id = params[:student_number]
         @@pw = params[:password]  	
       
      elsif stud_id == nil and password == nil
         stud_id  = @@id
         password = @@pw
      end
      
      e = "Student ID|:|Name|Degree Level|Degree Program|Year Level|Scholarship"
      
        String url = 'http://crs.upv.edu.ph/tacloban/student/loginAuthenticate.jsp?studentIDYear=&studentIDNumber='+stud_id+'&password='+password
        
        login = a.get(url)
        @stud_info = (login.search(".//td[@class='labelleftbrown8B']").text).to_s
        @stud_info =  @stud_info.gsub(/\s+/, " ")
   
        @stud_info.gsub!(/#{e}/, '@')
        d = @stud_info.split("@")
        info = Array.new
        d.each do |w|
            if !(w.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '') == "")
              info << w.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
            end
        end              
        
        @stud_info = info
        
        
        if(login.uri.to_s.include?("errorMsg"))
          @login[:error] = "Your credentials do not match our records!"
          redirect_to "/"
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

class RecordsController < ApplicationController
  @stud_info
  def index 
  end

  def home
      a = Mechanize.new
      stud_id = params[:student_number]
      password = params[:password]  	

      puts "student id: " + stud_id
      puts "password: " + password
      
      e = "Student ID|:|Name|Degree Level|Degree Program|Year Level|Scholarship"
      
      if(password != nil and stud_id != nil)
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
        
        pp login
        
        @stud_info = info
        
        if(login.uri.to_s.include?("errorMsg"))
          redirect_to action: "index"
        end
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

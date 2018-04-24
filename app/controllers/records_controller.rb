class RecordsController < ApplicationController

  @stud_info
  @schedule
  @id 
  @pw 
  @myGrades

  def index 
  end

  def student_login    
  end

  def faculty_login
  end

  def home
      a = Mechanize.new
      
      if params.has_key? :record
        stud_id  = params[:record][:user] 
        password = params[:record][:password]
        
        @id = stud_id
        @pw = password
      end
      
      if !stud_id.nil? and !password.nil?
         session[:user] = params[:record][:user]
         session[:password] = params[:record][:password]    
          
         @id = params[:record][:user]
         @pw = params[:record][:user]
       
      elsif stud_id.nil? and password.nil?
         stud_id  = session[:user]
         password = session[:password]
         
         @id = session[:user]
         @pw = session[:password]
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
        
        String url = 'http://crs.upv.edu.ph/tacloban/student/loginAuthenticate.jsp?studentIDYear=&studentIDNumber='+stud_id+'&password='+password
        
        login = a.get(url)
        
        String n = 'http://crs.upv.edu.ph/tacloban/student/gradesView.jsp?seiaccesstype=studentmenu&studentID='+stud_id

        g = a.get(n)


        String o  = 'http://crs.upv.edu.ph/tacloban/student/mySchedule.jsp?studentID='+stud_id+'&semID=2&ayID=38'
        h = a.get(o)
        headers = [:num, :subj, :section, :units, :schedule]
        rows= []
        h.search(".//tr[@class='recordentry']").each_with_index do |elem, ind|
            rows[ind] = {}
            elem.xpath('td').each_with_index do |l, index|
              i = l.text.to_s
              i = i.gsub(/\s+/, " ") 
              rows[ind][headers[index]] = i
            end
        end
        rows2= []
        h.search(".//tr[@class='recordentrylight']").each_with_index do |elem, ind|
        rows2[ind] = {}
          elem.xpath('td').each_with_index do |l, index|
            i = l.text.to_s
            i = i.gsub(/\s+/, " ") 
            rows2[ind][headers[index]] = i
          end
        end

        rows1 = rows + rows2
        @schedule = rows1.sort_by { |hsh| hsh[:num] }
         
        if(login.uri.to_s.include?("errorMsg"))
          flash[:error] = "Your credentials do not match our records!"
          redirect_to "/"
        end
  end
  def charts
  end
  
  def grades
    a = Mechanize.new
    if params.has_key? :record
        stud_id  = params[:record][:user] 
        password = params[:record][:password]
        
        @id = stud_id
        @pw = password
      end
      
      if !stud_id.nil? and !password.nil?
         session[:user] = params[:record][:user]
         session[:password] = params[:record][:password]    
          
         @id = params[:record][:user]
         @pw = params[:record][:user]
       
      elsif stud_id.nil? and password.nil?
         stud_id  = session[:user]
         password = session[:password]
         
         @id = session[:user]
         @pw = session[:password]
      end
      
    @myGrades = []
    String m = 'http://crs.upv.edu.ph/tacloban/student/loginAuthenticate.jsp?studentIDYear=&studentIDNumber='+@id+'&password='+@pw
    b = a.get(m)

    String o = 'http://crs.upv.edu.ph/tacloban/student/gradesView.jsp?seiaccesstype=studentmenu&studentID='+@id
    h = a.get(o)

    gradeForms =h.forms_with('grades')
    gfLength = gradeForms.length
    headers = [:subj, :units, :finalGrade,:rem1, :completionGrade, :rem2]
    for i in 0..(gfLength-1)
    myPage = gradeForms[i].submit
  
    table = myPage.at('table')

    rows = []
    count = 0
    myPage.search(".//tr").each_with_index do |elem, ind|
      rows[ind] = {}
      count = 0
      elem.xpath('td').each do |l|
        i = l.text.to_s
        i = i.gsub(/\s+/, " ").gsub(/\u00A0/, "")
      
        if i == "-----"
        else
          rows[ind][headers[count]] = i
          count = count + 1
        end
      end
    end
    for i in 1..5
      rows.delete_at(1)
    end

    rows.delete_at((rows.length)  -2)
    @myGrades << rows
    end
  end
  
  def studyplan
  end
  
  def incurred5
  end
end

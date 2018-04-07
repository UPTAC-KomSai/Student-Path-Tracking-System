class RecordsController < ApplicationController
  def index   
  end

  def home
  	a = Mechanize.new
  	a.get('http://crs.upv.edu.ph/') do |page|
  		# Click the Student link
  		login_page = a.click(page.link_with(:text => /Student/))
  		
  		# Submit the login form
  		login_form = login_page.form('StudentLogin')
  		login_form.studentIDNumber = params[:student_number]  			
  		login_form.password = params[:password]  		  		
  		pp login_form  		
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

class RecordsController < ApplicationController
  def index   
	#redirect_to "/home"
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
end

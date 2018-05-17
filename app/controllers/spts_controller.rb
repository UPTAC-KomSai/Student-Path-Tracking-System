require 'faculty'
require 'student'

class SptsController < ApplicationController
  def index
    if !session[:user].nil?
      if session[:user]['type'].eql? 'student'
        redirect_to '/student/dashboard'
      else
        # redirect_to '/faculty/dashboard'
      end
    end

    @title = 'SPTS'
  end

  def student_login
    @student = Student.new params[:spts][:user], params[:spts][:password]

    if @student.login
      session[:user] = {'id' => params[:spts][:user], 'password' => params[:spts][:password], 'type' => 'student'}
      redirect_to '/student/dashboard'
    else
      flash[:login_error] = "Your credentials do not match our records!"
      redirect_to '/'
    end
  end

  def faculty_login
  end

  def logout
    session.delete :user
    redirect_to '/'
  end
end

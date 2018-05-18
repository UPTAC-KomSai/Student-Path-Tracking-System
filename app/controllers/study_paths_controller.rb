class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@my_study_path = StudyPath.find_by id: params[:id]
	end

	def new
	end
end

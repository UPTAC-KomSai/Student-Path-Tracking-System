class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info
		@my_study_path = StudyPath.find_by degree_id: (Degree.find_by name: @course['degree_program'].gsub(".","")).id

		@title = 'SPTS - Study Path'
	end

	def new
		@title = 'SPTS - Add New Study Path'
	end

	def edit
		@title = 'SPTS - Edit Study Path'
	end

	def update
	end

	def destroy
	end

	def create
		render'show'
	end

	def update_subjects
		@title = 'SPTS - Update Subjects'
		@year = params['year']
		@semester = params['semester']

		@subjects = Subject.group(:subject_id)
	end

	def save_subjects
		render 'show'
	end
end

class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info
		@my_study_path = StudyPath.find_by degree_id: (Degree.find_by name: @course['degree_program'].gsub(".","")).id

		@years = StudyPathSubject.where(study_path_id: @my_study_path.id).distinct.pluck(:year)
		@semesters = StudyPathSubject.where(study_path_id: @my_study_path.id).distinct.pluck(:semester)

		@subjects = Array.new

		@years.each do |year|
			@semesters.each do |semester|
				sps = StudyPathSubject.where(["study_path_id = ? and year = ? and semester = ?", @study_path.id, @year, @semester]).distinct.pluck(:subject_id)
				subjs = Array.new
				sps.each do |subj|
					subjs << Subject.find(subj)
				end

				if !subjs.nil?
					@subjects << year + " Year - " + semester + " Semester"
					@subjects << subjs
				end
			end
		end

		puts @subjects

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
		@course = @student.basic_info
    @title = 'SPTS - New Study Path'
    @my_study_path = StudyPath.create(program_revision_code: params["study_path"]["program_revision_code"], title: params["study_path"]["title"],
    degree_id: (Degree.find_by name: @course['degree_program'].gsub(".","")).id)
    
    redirect_to "/study_paths/#{@my_study_path.id}"
	end

	def update_subjects
		@title = 'SPTS - Update Subjects'
		@year = params['year']
		@semester = params['semester']

		@current = StudyPathSubject.where(["study_path_id = ? and year = ? and semester = ?", @study_path.id, @year, @semester])
		@current_subjects = Array.new
		@current.each do |curr|
			@current_subjects << Subject.find(curr.subject_id)
		end

		@subjects = Subject.group(:subject_id)
	end

	def add_subject
		@study_path_id = params['study_path']
		@subject_id = params['subject']
		@year = params['year']
		@semester = params['semester']

		@study_path_subject = StudyPathSubject.create(study_path_id: @study_path_id, subject_id: @subject_id, year: @year, semester: @semester)

		redirect_to '/study_path/' + @study_path_id + '/update_subjects?semester=' + @semester + '&year=' + @year
	end
end

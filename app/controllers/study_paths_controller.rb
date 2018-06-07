class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info

		degree_id = Degree.where(name: @course['degree_program'].gsub(".","")).pluck(:id).first
		study_path_record = StudyPath.where(degree_id: degree_id).first

		study_path = {id: study_path_record.id, program_revision_code: study_path_record.program_revision_code, title: study_path_record.title}		
		puts study_path
		
		@my_subjects = StudyPathSubject.where(study_path_id: study_path[:id])
		# puts "@my_subjects = #{@my_subjects}"
		# @my_subjects.each do |subject|

		@entries = Array.new
		@my_subjects.each do |subject|			
			entry = Hash.new
			if subject[:subject_id] == nil && subject[:rgep] != nil
				entry[:subject] = RgepCluster.where(id: subject[:rgep]).distinct.pluck(:name)
				entry[:units] = RgepCluster.where(id: subject[:rgep]).distinct.pluck(:units)	
			else
				entry[:subject] = Subject.where(id: subject[:subject_id]).distinct.pluck(:subject_id)
				entry[:name] = Subject.where(id: subject[:subject_id]).distinct.pluck(:name)
				entry[:units] = Subject.where(id: subject[:subject_id]).distinct.pluck(:units)
				entry[:prerequisites] = Subject.where(id: subject[:subject_id]).distinct.pluck(:pre_req).join(",")			
			end
			@entries << entry
		end
		
		puts @entries

		# @myGrades = @student.grades
		# @totalUnits = 0

		# @entries = Array.new
		# @myGrades.each do |content|
		# 	entry = Array.new
		# 	content.each do |row|
		# 		if row[:subj].include? "Semester" or row[:subj].include? "Summer"
		# 			entry << row
		# 		end

		# 		if row.length != 1
		# 			subject = Hash.new
		# 			subject[:subject] = row[:subj]
		# 			temp = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:name).join(",")
		# 			subject[:name] = temp
		# 			subject[:units] = row[:units]
		# 			temp = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:pre_req).join(",")
		# 			subject[:prerequisites] = temp
		# 			subject[:grade] = row[:finalGrade]

		# 			if row[:finalGrade].include? " INC " or row[:finalGrade].include? " 4.0 "
		# 				if !row[:completionGrade].eql? " "
		# 					subject[:grade] = row[:completionGrade]
		# 				end
		# 			end

		# 			if (!row[:finalGrade].eql? " 5.0 " or !row[:finalGrade].eql? " 4.0 " or !row[:finalGrade].eql? " INC " or !row[:finalGrade].eql? " NO GRADE ") and !row[:units].include? "("
		# 				@totalUnits = @totalUnits + row[:units].to_i
		# 			end

		# 			if row[:finalGrade].eql? " INC " and !row[:completionGrade].eql? " NO GRADE "
		# 				if (!row[:completionGrade].eql? " 5.0 " or !row[:completionGrade].eql? " 4.0 ") and !row[:units].include? "("
		# 					@totalUnits = @totalUnits + row[:units].to_i
		# 				end
		# 			end

		# 			entry << subject
		# 		end
		# 	end
		# 	@entries << entry
		# end

		# puts @myGrades
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

class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info
		@my_study_path = StudyPath.find_by degree_id: (Degree.find_by name: @course['degree_program'].gsub(".","")).id

		@myGrades = @student.grades
		@totalUnits = @student.units_earned

		@entries = Array.new
		@myGrades.each do |content|
			entry = Array.new
			content.each do |row|
				if row[:subj].include? "Semester" or row[:subj].include? "Midyear"
					entry << row
				end

				if row.length > 3
					subject = Hash.new
					subject[:subject] = row[:subj]
					subject[:name] = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:name).join(",")
					subject[:units] = row[:units]
					subject[:prerequisites] = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:pre_req).join(",")
					subject[:grade] = row[:finalGrade]

					if row[:finalGrade].include? "INC" or row[:finalGrade].include? "4.0"
						if !row[:completionGrade].strip.eql? ""
							subject[:grade] = row[:completionGrade]
						end
					end

					entry << subject
				end
			end
			@entries << entry
		end

		@subject_codes = Array.new
		@entries.each do |entry|
			for i in 1...entry.length
				@subject_codes << entry[i]
			end
		end

		@blocks = Array.new
		@entries.each do |entry|
			block_row = Array.new
			for i in 1...entry.length
				block_row << entry[i][:subject]
				next_subjects = Array.new
				@subject_codes.each do |code|
					if code[:prerequisites].include? entry[i][:subject]
						next_subjects << code[:subject]
					end
				end
				block_row << next_subjects
			end
			@blocks << block_row
		end

		puts @blocks

		@title = "SPTS - Study Path"
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

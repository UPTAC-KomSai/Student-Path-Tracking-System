class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info
		@my_study_path = StudyPath.find_by degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id

		@myGrades = @student.grades
		@totalUnits = 0

		@entries = Array.new
		@myGrades.each do |content|
			entry = Array.new
			content.each do |row|
				if row[:subj].include? "Semester" or row[:subj].include? "Summer"
					entry << row
				end

				if row.length != 1
					subject = Hash.new
					subject[:subject] = row[:subj]
					temp = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:name).join(",")
					subject[:name] = temp
					subject[:units] = row[:units]
					temp = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:pre_req).join(",")
					subject[:prerequisites] = temp
					subject[:grade] = row[:finalGrade]

					if row[:finalGrade].include? " INC " or row[:finalGrade].include? " 4.0 "
						if !row[:completionGrade].eql? " "
							subject[:grade] = row[:completionGrade]
						end
					end

					if (!row[:finalGrade].eql? " 5.0 " or !row[:finalGrade].eql? " 4.0 " or !row[:finalGrade].eql? " INC " or !row[:finalGrade].eql? " NO GRADE ") and !row[:units].include? "("
						@totalUnits = @totalUnits + row[:units].to_i
					end

					if row[:finalGrade].eql? " INC " and !row[:completionGrade].eql? " NO GRADE "
						if (!row[:completionGrade].eql? " 5.0 " or !row[:completionGrade].eql? " 4.0 ") and !row[:units].include? "("
							@totalUnits = @totalUnits + row[:units].to_i
						end
					end

					entry << subject
				end
			end
			@entries << entry
		end
    my_units = Array.new
    
    @myGrades.each do |content|
       my_units << content[(content.length - 1)][:subj]
    end
    
    @totalUnits = 0;
    my_units.each do |unit|
      @totalUnits = @totalUnits + unit[32, 4].to_i
    end
		puts @myGrades
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
    @title = 'SPTS - New Study Path'
    
    if((StudyPath.find_by degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id).nil?)
      @my_study_path = StudyPath.create(program_revision_code: params["study_path"]["program_revision_code"], title: params["study_path"]["title"],
      degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id)
      @@subject_session = nil
    else
      @my_study_path = StudyPath.find_by degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id
      @my_study_path.program_revision_code = params["study_path"]["program_revision_code"]
      @my_study_path.title = params["study_path"]["title"]
      @my_study_path.save
    end
    redirect_to "/admins/#{@my_study_path.id}"
	end

	def update_subjects
		@title = 'SPTS - Update Subjects'
		@year = params['year']
		@semester = params['semester']
    @id = params['id']
    @subject_id = params['subject_id']
    @study_path = StudyPath.find_by id: @id
    
		@current = StudyPathSubject.where(["study_path_id = ? and year = ? and semester = ?", @id, @year, @semester])
		@current_subjects = Array.new
		@current.each do |curr|
			@current_subjects << Subject.find(curr.subject_id)
		end
    
    @study_path_subjects = StudyPathSubject.where study_path_id: @id
    if @study_path.subjects.count == 0
       @subjects = Subject.group(:subject_id)
    else
      @subjects = Subject.group(:subject_id)
      @study_path_subjects.each do |s|
        @subjects = (@subjects.where.not id: s.subject_id).group(:subject_id)
      end
    end
	end

	def add_subject
		@study_path_id = params['study_path']
		@subject_id = params['subject']
		@year = params['year']
		@semester = params['semester']

		@study_path_subject = StudyPathSubject.create(study_path_id: @study_path_id, subject_id: @subject_id, year: @year, semester: @semester)
		redirect_to '/study_path/' + @study_path_id + '/update_subjects?semester=' + @semester + '&year=' + @year+ '&subject_id=' + @subject_id
	end
  def remove_subject
		@study_path_id = params['study_path']
		@subject_id = params['subject']
		@year = params['year']
		@semester = params['semester']

		@study_path_subject = StudyPathSubject.find_by subject_id: @subject_id 
    @study_path_subject.destroy 
    redirect_to '/study_path/' + @study_path_id + '/update_subjects?semester=' + @semester + '&year=' + @year+ '&subject_id=' + @subject_id
	end
end

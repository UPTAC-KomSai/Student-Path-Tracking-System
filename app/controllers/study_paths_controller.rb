class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info
		@my_study_path = StudyPath.find_by degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id

		degree_id = Degree.where(name: @course['degree_program'].gsub(".","")).pluck(:id).first
		study_path_record = StudyPath.where(degree_id: degree_id).first

		@my_study_path = {id: study_path_record.id, program_revision_code: study_path_record.program_revision_code, title: study_path_record.title}				
		@my_subjects = StudyPathSubject.where(study_path_id: @my_study_path[:id])
		# puts "@my_subjects = #{@my_subjects}"
		# @my_subjects.each do |subject|

		@myGrades = @student.grades
		
		temp_year = ""
		temp_sem = ""

		@entries = Array.new	
		@entry_persem = Hash.new
		@subject_persem = []

		@my_subjects.each_with_index do |subject, index|			
			if temp_year == "" then temp_year = subject[:year] end
			if temp_sem == "" then temp_sem = subject[:semester] end

			if temp_year != subject[:year] || temp_sem != subject[:semester]	
				@entry_persem[:year] = temp_year
				@entry_persem[:sem] = temp_sem
				@entry_persem[:subjects] = @subject_persem				
				temp_year = subject[:year]
				temp_sem = subject[:semester]				
				@entries << @entry_persem
				@entry_persem = Hash.new
				@subject_persem = Array.new
			end

			entry = Hash.new
			if subject[:subject_id] == nil && subject[:rgep] != nil
				entry[:subject] = RgepCluster.where(id: subject[:rgep]).distinct.pluck(:name).first
				entry[:units] = "#{RgepCluster.where(id: subject[:rgep]).distinct.pluck(:units).first}.0"
			else
				entry[:subject] = Subject.where(id: subject[:subject_id]).distinct.pluck(:subject_id).first
				entry[:name] = Subject.where(id: subject[:subject_id]).distinct.pluck(:name).first
				entry[:units] = "#{Subject.where(id: subject[:subject_id]).distinct.pluck(:units).first}.0"				
			end			
			fake_subject_id = Subject.where(id: subject[:subject_id]).distinct.pluck(:fake_subject_id).join(",")
			fake_subject_name = FakeSubject.where(id: fake_subject_id).distinct.pluck(:subject_code).join(",")		
			entry[:prerequisites] = fake_subject_name

			@subject_persem << entry
		end
		
		puts @entries		
		@totalUnits = 0
		subjects_taken = Array.new
		# ah_taken = Array.new
		# ssp_taken = Array.new
		# mst_taken = Array.new
		# elective_taken = Array.new
		# pe_taken = Array.new
		# nstp_taken

		# puts @myGrades

		@myGrades.each do |sem|
			entry_persem = Array.new
			sem.each do |entries|				
				if entries.length > 1
					subject = Hash.new
					subject[:subject] = entries[:subj]
					subject[:name] = Subject.where(subject_id: "#{entries[:subj]}").distinct.pluck(:name).join(",")
					subject[:units] = entries[:units]
					subject[:prerequisites] = Subject.where(subject_id: "#{entries[:subj]}").distinct.pluck(:pre_req).join(",")
					subject[:grade] = entries[:finalGrade]


					if entries[:finalGrade].include? " INC " or entries[:finalGrade].include? " 4.0 "
						if !entries[:completionGrade].eql? " "
							subject[:grade] = entries[:completionGrade]
						end
					end

					if (!entries[:finalGrade].eql? " 5.0 " or !entries[:finalGrade].eql? " 4.0 " or !entries[:finalGrade].eql? " INC " or !entries[:finalGrade].eql? " NO GRADE ") and !entries[:units].include? "("
						@totalUnits = @totalUnits + entries[:units].to_i
					end

					if entries[:finalGrade].eql? " INC " and !entries[:completionGrade].eql? " NO GRADE "
						if (!entries[:completionGrade].eql? " 5.0 " or !entries[:completionGrade].eql? " 4.0 ") and !entries[:units].include? "("
							@totalUnits = @totalUnits + entries[:units].to_i
						end
					end

					entry_persem << subject
				end
			end
			subjects_taken << entry_persem
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

		#puts @myGrades
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

class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info

		degree_id = Degree.where(name: @course['degree_program'].gsub(".","")).pluck(:id).first
		study_path_record = StudyPath.where(degree_id: degree_id).first

		@my_study_path = {id: study_path_record.id, program_revision_code: study_path_record.program_revision_code, title: study_path_record.title}				
		@my_subjects = StudyPathSubject.where(study_path_id: @my_study_path[:id])	

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
		
		@totalUnits = 0
		subjects_taken = Array.new		
		ah_taken = Array.new
		ssp_taken = Array.new
		mst_taken = Array.new

		# Replaces the year and sem entry with the year and sem the subjects were taken
		curr_year = ""
		curr_sem = ""
		counter = 0
		@myGrades = @student.grades
		@myGrades.each do |entry|
			entry.each do |row|					
				if row[:subj].include? "Semester" or row[:subj].include? "Summer"
					token = row[:subj].split("/")
					curr_year = token[1].gsub(")", "").strip
					curr_sem = token[0].gsub("(", "").strip
					
					@entries[counter][:year] = "#{@entries[counter][:year]} - #{curr_year}"
					@entries[counter][:sem] = curr_sem
					counter += 1
				end			

				if row.length > 1
					subject = Hash.new
					subject[:subject] = row[:subj]
					subject[:name] = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:name).join(",")
					subject[:units] = row[:units]
					subject[:prerequisites] = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:pre_req).join(",")
					subject[:grade] = row[:finalGrade]			
					if row[:finalGrade].include? "INC" and (row[:completionGrade].strip).length > 0
						puts "============ completionGrade: [#{row[:completionGrade].strip}]"
						subject[:grade] = row[:completionGrade]
					end

					if subject[:prerequisites].include?("pre_req")
						subject[:prerequisites] = ""
					end

					isGe = Subject.where(subject_id: "#{row[:subj]}").distinct.pluck(:isGe).first
					if isGe != false
						rgep = nil
						subject_code = row[:subj]
						puts "subject_code: [#{subject_code}]"
						if !((Subject.find_by subject_id: subject_code).nil?)	
							rgep = (Subject.find_by subject_id: row[:subj]).rgep_id
						else
							if (subject_code.include?("Eng") or subject_code.include?("Comm") or subject_code.include?("Lit"))								
								ah_taken << subject
								@entries[counter-1][:subjects].each do |subj|
									if subj[:subject] == "GE (AH)"									
										puts "subj[:subject]: [#{subj[:subject]}], subject[:subject]: [#{subject[:subject]}]"
										subj[:subject] = subject[:subject]
										subj[:name] = "--" unless subject[:name] != ""
										subj[:units] = subject[:units]										
										subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
										subj[:grade] = subject[:grade] 
									end
								end
							elsif (subject_code.include?("Soc") or subject_code.include?("Philo") or subject_code.include?("Psych") or subject_code.include?("Hist"))
								ssp_taken << subject
								@entries[counter-1][:subjects].each do |subj|
									if subj[:subject] == "GE (SSP)"
										subj[:subject] = subject[:subject]
										subj[:name] = "--" unless subject[:name] != ""
										subj[:units] = subject[:units]										
										subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
										subj[:grade] = subject[:grade] 
									end
								end
							elsif (subject_code.include?("Envi") or subject_code.include?("Bio"))								
								mst_taken << subject
								@entries[counter-1][:subjects].each do |subj|
									if subj[:subject] == "GE (MST)"
										subj[:subject] = subject[:subject]
										subj[:name] = "--" unless subject[:name] != ""
										subj[:units] = subject[:units]										
										subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
										subj[:grade] = subject[:grade] 
									end
								end
							elsif (subject_code.include?("NSTP"))								
								@entries[counter-1][:subjects].each do |subj|
									if subj[:subject] == "NSTP"
										subj[:subject] = subject[:subject]
										subj[:name] = "--" unless subject[:name] != ""
										subj[:units] = subject[:units]										
										subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
										subj[:grade] = subject[:grade] 
									end
								end
							elsif (subject_code.include?("PE"))								
								@entries[counter-1][:subjects].each do |subj|
									if subj[:subject] == "PE 2"
										subj[:subject] = subject[:subject]
										subj[:name] = "--" unless subject[:name] != ""
										subj[:units] = subject[:units]										
										subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
										subj[:grade] = subject[:grade] 
									end
								end
							end								
						end

						if rgep != nil
							rgep_name = (RgepCluster.find_by id: rgep).name
							if rgep_name == "GE (AH)"
								#puts "inculdes AH"
								ah_taken << subject							
								@entries[counter][:subjects].each do |subj|
									if subj[:subject] == "GE (AH)"
										subj[:subject] = subject[:subject]
										subj[:name] = subject[:name]
										subj[:units] = subject[:units]
										subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
										subj[:grade] = subject[:grade] 
									end
								end

							elsif rgep_name == "GE (MST)"
								mst_taken << subject
							elsif rgep_name == "GE (SSP)"
								ssp_taken << subject
								@entries[counter-1][:subjects].each do |subj|
									if subj[:subject] == "GE (SSP)"									
										subj[:subject] = subject[:subject]
										subj[:name] = subject[:name]
										subj[:units] = subject[:units]
										subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
										subj[:grade] = subject[:grade] 
									end
								end
							end			
						end											
					end

					inStudyPlan = false
					for i in 0...@entries.length do
						@entries[i][:subjects].each do |subj|
							if subj[:subject].strip.include?(subject[:subject].strip)								
								subj[:grade] = subject[:grade] 
								inStudyPlan = true
								break
							end							
						end
						if inStudyPlan then break end
					end					

					isStored = false
					if !inStudyPlan
						for i in 0...@entries.length do
							@entries[i][:subjects].each do |subj|
								if subj[:subject].strip.include?("Elective")
									subj[:subject] = subject[:subject]
									subj[:name] = subject[:name]
									subj[:name] = "--" unless subject[:name] != ""
									subj[:units] = subject[:units]
									subj[:prerequisites] = "N/A" unless subject[:prerequisites] != ""
									subj[:grade] = subject[:grade] 
									isStored = true
									break
								end
							end
							if isStored then break end
						end
					end

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
					
				end
			end
		end
				
		# elective_taken = Array.new
		# pe_taken = Array.new
		# nstp_taken

		# puts @myGrades

		# entry_persem = Hash.new
		# subject_persem = Array.new
		# @myGrades.each do |sem|			
		# 	sem.each do |entries|					

				
		# 	end
		# 	subjects_taken << entry_persem
		# end

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

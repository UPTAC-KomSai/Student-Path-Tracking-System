# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'rubygems'
require 'mechanize'
require 'nokogiri'

division_names = ["MGT", "NSMD", "HUM", "SOCSCI"]

#Add the divisions
division_names.each do |div| 
  Division.create(name: div)
end

agent = Mechanize.new
subjects_url = 'http://crs.upv.edu.ph/views/subjectOfferings.jsp?view=subjects&find=&unitID=null&campus=4&degreelevel=U'
current_page = agent.get subjects_url
html_doc = Nokogiri::HTML current_page.body
data = html_doc.xpath "//tr[@class='recordentry' or @class='recordentrylight']/td/descendant-or-self::*/text()"
  
temp = []

data.each do |w|
  w = w.to_s.gsub! /\s+/, ' '
  if w != nil
    temp << w
  end
end

temp.delete_if { |e| e == " "}
temp.delete_if { |e| e =~ /Date Implemented:/}
temp.delete_if { |e| e =~ /Substitute/}
temp.delete_if { |e| e =~ /View Outline/} 

i = 0
num = temp.length
course_id = ""
course_name = ""
course_desc = ""
course_units = ""
course_prereq = ""
course_div_tok = []
course_div = ""

course_id_list = []

prereq_list = Hash.new

while i < num do
  if temp[i] =~ /^ (\d+)\. /
  	course_id = temp[i + 1]
  	#puts "[#{course_id}]"
  	course_id = course_id.strip
  	print "   [course_id: #{course_id}]"
  	course_name = temp[i + 3]
  elsif temp[i] =~ /^ Description: /
  	course_desc = temp[i + 1]
  	if course_desc.length == 3
  	  #puts "pong"
  	  course_units = temp[i + 2]
  	  course_div_tok = temp[i + 3].split(/ /)
  	elsif course_desc.length > 3
  	  #puts "[#{course_desc}]"\
  	  course_units = temp[i + 3]
  	  course_div_tok = temp[i + 4].split(/ /)
  	  #puts course_div
  	end
  	course_div_tok = course_div_tok[2...course_div_tok.length]
  	course_div = course_div_tok[0]
  	#course_div.delete_if { |e| e == "   " }
  	#puts "Cluster======"
  	#puts course_div

  elsif temp[i] =~ /^ Pre-requisite/
  	hasPrereq = temp[i+1] =~ /^ Description: /
  	if hasPrereq != 0 
  	  course_prereq = temp[i+2]
  	else
  	  course_prereq = nil
  	end
  end

  if temp[i + 1] =~ /^ (\d+)\. /
  	#puts course_div

  	if course_div != nil
  	  if course_div.include?("\(")
  	    course_div = course_div.chomp("\(")
  	  end

  	  division_id = ""
  	  division =  Division.where(name: course_div).first
  	  if division != nil
  	    division_id = division.id
  	    print division.name
  	  else
  	  	print "nil"
  	  end

  	  if course_prereq != nil
  	  	course_id_list << course_id
  	  	prereq_list[course_id] = course_prereq
  	   # puts course_prereq
  	  else
  	  	prereq_list[course_id] = nil
  	  	#puts "nil"  	   
   	  end

   	  #puts "ci = [#{course_id}]"
   	  Subject.create(division_id: division_id, subject_id: course_id, name: course_name, description: course_desc, units: course_units)
   end
  else
  	if i == num - 1
  	  if course_div != nil
  	    if course_div.include?("\(")
  	      course_div = course_div.chomp("\(")
  	    end

  	    division_id = ""
  	    division =  Division.where(name: course_div).first
  	    if division != nil
  	      division_id = division.id
  	      print division.name
  	    else
  	  	  print "nil"
  	    end

  	    if course_prereq != nil
  	  	  course_id_list << course_id
  	  	  prereq_list[course_id] = course_prereq
  	     puts course_prereq
  	    else
  	      prereq_list[course_id] = nil  	   
  	      puts "nil"
   	    end
  	   end
  	end
  end
  
  i+=1
end

#course_id_list.each do |e| puts "#{e} => #{prereq_list[e]}" end

course_id_list.each do |cid| 
	prereq = prereq_list[cid] 
	course_prereq_list = prereq.split(",")
	
	#puts course_prereq_list.length
	prereq_str = course_prereq_list[0]
	prereq_str = prereq_str.strip
	prereq_obj = Subject.where(subject_id: prereq_str).first

	if prereq_obj != nil
	 # puts "not nil"
	  prereq_id = prereq_obj.id

	  puts "[course_id: #{cid}] = [prereq_str: #{prereq_str}]"
	  subject = Subject.where(subject_id: cid).first
	  if subject != nil
	     subject.subjects_id = prereq_id
	 else
	 	puts "    nil"
	 end

	end

    if course_prereq_list.length > 1
		subj_to_replicate = Subject.where(subject_id: cid).first
		#puts "replicate #{subj_to_replicate.subject_id}" 
		var = 1
		while var < course_prereq_list.length do
			prereq_str = course_prereq_list[var]
			prereq_str = prereq_str.strip
			#puts "  [#{prereq_str}]"
			prereq_obj = Subject.where(subject_id: prereq_str).first

			if prereq_obj != nil
				#puts "not nil"
				prereq_id = prereq_obj.id
				#puts " === #{prereq_id}"
			    Subject.create(division_id: subj_to_replicate.division_id, subject_id: subj_to_replicate.subject_id, 
			 	name: subj_to_replicate.name, description: subj_to_replicate.description, units: subj_to_replicate.units, 
				subjects_id: prereq_id)
			end

			var += 1
		end
    end
end

data = Subject.all
puts data.length
#puts "div = #{data.division_id}, id = #{data.subject_id}, name = #{data.name}, description = #{data.description}, units = #{data.units}, prereqs = #{data.subjects_id}"
data.each do |e|
  #puts e.subjects_id
  prq = Subject.where(subjects_id: e.subjects_id).first
  prq_id = prq.subject_id
  #puts "div = #{e.division_id}, id = #{e.subject_id}, prereqs = #{prq_id}"
end
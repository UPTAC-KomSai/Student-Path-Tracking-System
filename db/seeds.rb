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
  if temp[i] =~ /^ (\d+). /
  	course_id = temp[i + 1]
  	#puts "[#{course_id}]"
  	course_id = course_id.strip
  	#puts "   [#{course_id}]"
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

  if temp[i + 1] =~ /^ (\d+). /
  	#puts course_div

  	if course_div != nil
  	  if course_div.include?("\(")
  	    course_div = course_div.chomp("\(")
  	  end

  	  division_id = ""
  	  division = Division.where(name: course_div).first
  	  if division != nil
  	    division_id = division.id
  	  end

  	  if course_prereq != nil
  	  	course_id_list << course_id
  	  	prereq_list[course_id] = course_prereq
  	  	#course_prereq_list = course_prereq.split(",")
  	  	#course_prereq_list.each do |e| e.strip end

  	  	#puts course_prereq_list.length
  	  	#puts "   id = #{course_id}"
  	    #course_prereq_list.each do |subject_id| 
  	    #  subject_id = subject_id.strip
  	    #  print "     [#{subject_id}]"
  	    #  prereq = Subject.where(subject_id: subject_id).first
  	    #  if prereq != nil
  	    #  	puts " = not nil"
  	    #  	prereq_id = prereq.id
  	    #  	prereq_course_id = prereq.subject_id
  	      	#puts "    === " + prereq_course_id
  	      	#puts "div = #{division_id}, id = #{course_id}, name = #{course_name}, description = #{course_desc}, units = #{course_units}, prereqs = #{prereq_id}"
  	    #    Subject.create(division_id: division_id, subject_id: course_id, name: course_name, description: course_desc, units: course_units, subjects_id: prereq_id)
  	    #  else
  	    #  	puts " = nil"
  	    #  end
  	    #end
  	  else
  	  	prereq_list[course_id] = nil
  	    #Subject.create(division_id: division_id, subject_id: course_id, name: course_name, description: course_desc, units: course_units)
   	  end
   end
  end
  
  i+=1
end


course_id_list.each do |e| puts e end
#prereq_list.each do |e|
#	puts 
#end
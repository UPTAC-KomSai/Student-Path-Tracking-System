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

agent = Mechanize.new
subjects_url = 'http://crs.upv.edu.ph/views/subjectOfferings.jsp?view=subjects&find=&unitID=null&campus=4&degreelevel=U'
current_page = agent.get subjects_url
html_doc = Nokogiri::HTML current_page.body
 
 subjects = []
 subject_headers = [:code, :title, :pre_req, :description, :rgep_cluster, :credit, :degree_level, :offering_unit_campus]
 current_page.search(".//tr[@class='recordentry' or @class='recordentrylight']").each_with_index do |elem, ind|
    subjects[ind] = {}
    counter = 0
    subjects[ind][subject_headers[0]] = elem.xpath('td[2]/text()').to_s.gsub(/\s+/, " ").gsub(/\u00A0/, "")
    elem.xpath('td').each do |a|
     count = 0
     ii = a.text.to_s
     ii = ii.gsub(/\s+/, " ").gsub(/\u00A0/, "")
     
     if counter == 1
         a.xpath("i").each do |b|
          b.search("font[@class='labelleftgreen7B']").each do |c|
            i = c.text.to_s
            i = i.gsub(/\s+/, " ").gsub(/\u00A0/, "")
            count += 1
            if(count == 2 && i.length > 40)
              count+=1
            end
            if(count == 3 && i.include?("GE ("))
              count+=1
            end
              subjects[ind][subject_headers[count]] = i  
          end
        end
     elsif counter == 2
         subjects[ind][subject_headers[5]] = ii
     elsif counter == 3
         subjects[ind][subject_headers[6]] = ii
     elsif counter == 4
         subjects[ind][subject_headers[7]] = ii
     end
     counter += 1
    end
  end
  
 subjects[170][:pre_req]= subjects[170][:description]
 subjects[170][:description] = " "
 subjects[36][:pre_req]= subjects[36][:description]
 subjects[36][:description] = " "
subjects.each_with_index do |c, ind|
  subjects[ind][:offering_unit_campus]= subjects[ind][:offering_unit_campus].gsub("- Tacloban City", "").gsub(" ", "")
end
division_names = ["MGT", "NSMD", "HUM", "SOCSCI"]

degrees = ["BS IN ACCOUNTANCY", "BS IN MANAGEMENT", "BS (BIOLOGY)",  "BS IN COMPUTER SCIENCE","BA (SOCIAL SCIENCE) ECONOMICS",
"BA (SOCIAL SCIENCE) POLITICAL SCIENCE","BA (PSYCHOLOGY)","BA (COMMUNICATION ARTS)"]
degree_code = ["BSA", "BSM", "BS-Bio", "BSCS", "BA-Econ", "BA-PolSci", "BA-Psych", "BACA"]

#Add the divisions
division_names.each do |div| 
  Division.create(name: div)
end

degrees.each_with_index do |degree, index| 
  if index == 0 or index == 1
    Degree.create(division_id: (Division.find_by name: "MGT").id, code: degree_code[index], name: degree)
  elsif index == 2 or index == 3
    Degree.create(division_id: (Division.find_by name: "NSMD").id, code: degree_code[index], name: degree)
  elsif index == 4 or index == 5 or index == 6
    Degree.create(division_id: (Division.find_by name: "SOCSCI").id, code: degree_code[index], name: degree)
  elsif index == 7
    Degree.create(division_id: (Division.find_by name: "HUM").id, code: degree_code[index], name: degree)
  end
end

subjects.each do |s|
  FakeSubject.create subject_code: s[:code].strip
end

subjects.each do |subj|
  units = subj[:credit].to_i
  isGE = false
  if (subj[:rgep_cluster].nil?)
  else
    if subj[:rgep_cluster].include? "GE"
      isGE = true
    end
  end
  
  if subj[:pre_req] == " " or subj[:pre_req].nil?
    Subject.create(division_id: (Division.find_by name: subj[:offering_unit_campus]).id, fake_subject_id: nil,subject_id: subj[:code].strip, name: subj[:title], description: subj[:description],
    pre_req: subj[:pre_req] ,units: units,isGe: isGE)
  else
    pre_req = subj[:pre_req].split(",")
    pre_req.each do |p|
      p = p.strip
      if (FakeSubject.find_by subject_code: p).nil?
        Subject.create(division_id: (Division.find_by name: subj[:offering_unit_campus]).id, fake_subject_id: nil,subject_id: subj[:code].strip, name: subj[:title], description: subj[:description],
        units: units,isGe: isGE)
      else
        Subject.create(division_id: (Division.find_by name: subj[:offering_unit_campus]).id, fake_subject_id: (FakeSubject.find_by subject_code: p).id,subject_id: subj[:code].strip, name: subj[:title], description: subj[:description],
        pre_req: subj[:pre_req], units: units,isGe: isGE)
      end
    end
  end
end
# This class is basically used to represent a student.
# Since this rails app do not have the right to store information from CRS, this class serves as the API to scrape data from there.

require 'rubygems'
require 'mechanize'
require 'nokogiri'

class Student
  attr_accessor :student_number, :password

  def initialize student_number, password
    @student_number = student_number
    @password = password
  end

  def login
    if @student_number.nil? or @password.nil?
      return false
    end

    @agent = Mechanize.new
    login_url = 'http://crs.upv.edu.ph/tacloban/student/loginAuthenticate.jsp?studentIDYear=&studentIDNumber='+@student_number+'&password='+@password
    @current_page = @agent.get login_url

    if @current_page.uri.to_s.include? 'errorMsg'
      return false
    end

    return true
  end

  def basic_info
    html_doc = Nokogiri::HTML @current_page.body
    data = html_doc.xpath "//td[@class='labelleftbrown8B' and @width='80%']/text()"
    data = data.to_s
    data.gsub! /\s+/, ' '
    exclude = 'Student ID|Name|Degree Level|Degree Program|Year Level|Scholarship|:'
    data.gsub! /#{exclude}/, '@'
    data = data.split '@'
    index = ['student_number', 'name', 'degree_program', 'degree_level', 'year_level', 'scholarship']
    i = 0
    info = {'student_number' => '', 'name' => '', 'degree_program' => '', 'degree_level' => '', 'year_level' => '', 'scholarship' => ''}
    data.each do |w|
      if !w.eql? ' ' and !w.eql? ''
        info[index[i]] = w.strip

        i = i + 1
      end
    end

    return info
  end

  def current_schedule
    grades_schedule_menu_url = 'http://crs.upv.edu.ph/tacloban/student/gradesView.jsp?seiaccesstype=studentmenu&studentID='+@student_number
    @current_page = @agent.get grades_schedule_menu_url
    html_doc = Nokogiri::HTML @current_page.body
    data = html_doc.xpath "//input[@name='ayID']/@value"
    current_ay_id = data.last.value
    data = html_doc.xpath "//input[@name='semID']/@value"
    current_sem_id = data.last.value

    schedule_view_url = 'http://crs.upv.edu.ph/tacloban/student/mySchedule.jsp?studentID='+@student_number+'&semID='+current_sem_id+'&ayID='+current_ay_id
    @current_page = @agent.get schedule_view_url
    html_doc = Nokogiri::HTML @current_page.body
    data = html_doc.xpath "//tr[@class='recordentry' or @class='recordentrylight']/td/descendant-or-self::*/text()"
    temp = []
    data.each do |w|
      w = w.to_s.gsub! /\s+/, ' '
      if w.eql? ' '
        next
      else
        temp << w.strip
      end
    end
    schedule = {}
    temp.each_slice(6).to_a.each do |subject|
      schedule[subject[0]] = subject.drop 1
    end
    return schedule
  end

  def grades
    @myGrades = []

    String o = 'http://crs.upv.edu.ph/tacloban/student/gradesView.jsp?seiaccesstype=studentmenu&studentID='+@student_number
    h = @agent.get(o)

    gradeForms =h.forms_with('grades')
    gfLength = gradeForms.length
    headers = [:subj, :units, :finalGrade,:rem1, :completionGrade, :rem2]
    for i in 0..(gfLength-1)
    myPage = gradeForms[i].submit

    table = myPage.at('table')

    rows = []
    count = 0
    myPage.search(".//tr").each_with_index do |elem, ind|
      rows[ind] = {}
      count = 0
      elem.xpath('td').each do |l|
        i = l.text.to_s
        i = i.gsub(/\s+/, " ").gsub(/\u00A0/, "")

        if i == "-----"
        else
          rows[ind][headers[count]] = i
          count = count + 1
        end
      end
    end
    for i in 1..5
      rows.delete_at(1)
    end

    rows.delete_at((rows.length)  -2)
    @myGrades << rows
    end

    my_units = Array.new 
    @myGrades.each do |content|
      my_units << content[(content.length - 1)][:subj]
      content[0][:subj].tr!('()', '')
      
      my_units.each do |unit|
        if !unit.include? "GWA" and !unit.include? "Class Standing"
          content[(content.length - 1)][:subj] = unit
          content[(content.length - 1)][:units] = "Class Standing: No Basis"
          content[(content.length - 1)][:finalGrade] = "GWA: No Basis"
          next
        end

        content[(content.length - 1)][:subj] =  unit[0, unit.index("Class")]
        content[(content.length - 1)][:units] =  " " + unit[unit.index("Class"), unit.index("GWA") - unit.index("Class")]
        content[(content.length - 1)][:finalGrade] = " "+ unit[unit.index("GWA"), unit.length - unit.index("GWA") -1]
      end
    end

    return @myGrades
  end

  def units_earned
    @myGrades = self.grades

    my_units = Array.new
    
    @myGrades.each do |content|
       my_units << content[(content.length - 1)][:subj]
    end
    
    @total_units = 0;
    my_units.each do |unit|
      @total_units = @total_units + unit[32, 4].to_i
    end

    return @total_units
  end

  def units_remaining

  end
end

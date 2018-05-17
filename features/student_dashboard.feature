Feature: Student Dashboard navigation
	
	As a student
	I want to be able to navigate the dashboard
	So that I can see the summary of my study path

Scenario: Student navigates dashboard
	Given I am on the "Dashboard"
	Then I should be able to see button "Personal Profile"
	And I should be able to see button "Schedule"
	And I should be able to see button "Grade"
	And I should be able to see button "Schedule"
	And I should be able to see button "Charts"
  And I should be able to see button "Study Plan"



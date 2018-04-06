Feature: Teacher Dashboard navigation
	
	As a Teacher
	I want to be able to navigate the dashboard
	So that I can see the summary of my performance

Scenario: Teacher navigates dashboard
	Given I am on the "Dashboard"
	Then I should be able to see button "Account information"
	And I should be able to see button "Schedule"
	And I should be able to see button "Grades"
	And I should be able to see button "Class syllabus"
	And I should be able to see button "Settings"
	And I should be able to see button "Charts"



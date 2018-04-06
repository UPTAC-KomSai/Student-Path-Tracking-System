Feature: Student Account Information
	
	As a student
	I want to be able to navigate my account information
	So that I can see my personal information
	
Scenario: Student navigates account information
	Given I am on the "Account Information"
	Then I should be able to see "Student Number: 201801234"
	And I should be able to see "Name: TAMAD, JUAN"
	And I should be able to see "Sex: Male"
	And I should be able to see "Degree: B.S. IN COMPUTER SCIENCE"
	And I should be able to see "Year Level: 1"
	And I should be able to see "Student Type: Regular"
	And I should be able to see "Email Address: juan_tamad@up.edu.ph"
	
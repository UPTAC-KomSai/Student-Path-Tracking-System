Feature: User login
	As a user
	I should be able to login to the website using my crs login credentials
	So that I can view my dashboard

Scenario: User visits the site
	Given I am on the landing page
	Then I should see the "Login Form"

Scenario: Student logs in
	Given I login as "Student"
	And I fill in "Student Number" with "201514567"
	And I fill in "Password" with "201514567"
	And I click "Login"
	Then I should see my dashboard

Scenario: Faculty logs in	
	Given I login as "Faculty"
	And I fill in "Username" with "juan"
	And I fill in "Password" with "*********"
	And I click "Login"
	Then I should see my dashboard

Feature: User login
	As a user
	I should be able to login to the website using my crs login credentials
	So that I can view my dashboard

Scenario: User visits the site
	Given I am on the landing page
	Then I should see the "Login Form"
  
Scenario: Student logs in successfully
	Given I login as "Student"
	And I fill in "Student Number" with "201510778"
	And I fill in "Password" with "201510778"
	And I click "Login"
	Then I should see my dashboard
  
Scenario: Student logs in with wrong credentials
	Given I login as "Student"
	And I fill in "Student Number" with "201510778"
	And I fill in "Password" with "201510"
	And I click "Login"
	Then I should see the login page

Scenario: Faculty logs in	with wrong credentials
	Given I login as "Faculty"
	And I fill in "Username" with "juan"
	And I fill in "Password" with "*********"
	And I click "Login"
	Then I should see the login page

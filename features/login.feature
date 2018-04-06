Feature: User login
As a user
I should be able to login to my account
So that I can view my dashboard

Scenario: Student logins to his/her dashboard
Given I am on the landing page
Then I should see the "Login Form"
When I choose "Student" as login type
And I fill in "Student Number" with "201514567"
And I fill in "Password" with "201514567"
And I click "Login"
Then I should see my dashboard

Scenario: Faculty logins to his/her dashboard
Given I am on the landing page
Then I should see the "Login Form"
When I choose "Faculty" as login type
And I fill in "Username" with "juan"
And I fill in "Password" with "*********"
And I click "Login"
Then I should see my dashboard

@student_number = nil
@password = nil
Given("I am on the landing page") do
  visit '/'
end

Then("I should see the \"Login Form\"") do
  expect(page).to have_selector("input", :count => 6)
end

Given("I login as {string}") do |string|
  visit '/'
end

Given("I fill in {string} with {string}") do |string, string2|
  @stud_number = string
  @password = string2
  
  fill_in "student_number", with: string, visible: false
	fill_in "password", with: string2, visible: false
end

Then("I should see the login page") do
  visit '/'
end

Given("I click {string}") do |string|
  click_button string
end

Then("I should see my dashboard") do
    expect(page).to have_content("My Dashboard")
end

Given("I am on the {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be able to see {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be able to see a graph showing my progress every semester") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be able to see button {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given("I am on the grades") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be able to see a table of my grades") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be able to see toggle button {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should be able to see a table of my schedule") do
  pending # Write code here that turns the phrase above into concrete actions
end
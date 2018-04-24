Given("I am on the landing page") do
  visit '/'
end

Then("I should see the \"Login Form\"") do
  expect(page).to have_selector("input", :count => 6)
end

Given("I login as {string}") do |string|
    visit "#{string}_login"
end

Given("I fill in {string} with {string}") do |string, string2|
    fill_in "#{string}", with: "#{string2}"
end

Given("I click {string}") do |string|
   save_and_open_page
  click_button "#{string}"
end

Then("I should see my dashboard") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should see the login page") do
 visit("/")
 expect(page).to have_content ("Your credentials do not match our records!")
end
Feature: Short Form Application
    As a web user
    I should be able to fill out the short form application
    In order to apply online to a listing

    Scenario: Submitting a basic application, creating an account on the confirmation page
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate I will live alone
      And I indicate living in public housing
      And I indicate no priority
      And I indicate having vouchers
      And I fill out my income as "25000"
      And I continue past the Lottery Preferences intro
      And I opt out of Live/Work preference
      And I opt out of Assisted Housing preference
      And I don't choose COP/DTHP preferences
      And I continue past the general lottery notice page
      And I fill out the optional survey
      And I confirm details on the review page
      And I continue confirmation without signing in
      And I agree to the terms and submit
      Then I should see my lottery number on the confirmation page
      # now that we've submitted, also create an account
      When I click the Create Account button
      And I fill out my account info with my locked-in application email
      And I wait "18" seconds
      And I submit the Create Account form
      Then I should be on the login page with the email confirmation popup

    Scenario: Creating an account in order to "Save and Finish Later"
      Given I go to the first page of the Test Listing application
      When I fill out the Name page with default info
      And I fill out the Contact page with default info
      And I confirm my address
      And I select a friend as an alternate contact
      And I fill out my alternate contact's name
      And I fill out my alternate contact's info
      And I indicate living with other people
      And I add a default household member
      And I confirm their address
      And I indicate being done adding people
      And I indicate not living in public housing
      And I enter "2500" for my monthly rent
      And I indicate being a veteran
      And I indicate having a developmental disability
      And I indicate need ADA features for vision and hearing
      And I do not indicate having vouchers
      And I fill out my income as "33333"
      And I continue past the Lottery Preferences intro
      And I select "Coleman Francis" for "Live in San Francisco" in Live/Work preference
      And I upload a "Gas bill" as my proof of preference for "liveInSf"
      And I click the Next button on the Live/Work Preference page
      And I select Rent Burdened Preference
      And I upload a copy of the lease
      And I upload proof of rent payment
      And I click the Next button on the Rent Burdened Preference page
      And I select "Coleman Francis" for "certOfPreference" preference
      And I select "Coleman Francis" for "displaced" preference
      And I submit my preferences
      And I fill out the optional survey
      And I click the Save and Finish Later button
      And I fill out my account info
      And I submit the Create Account form
      And I confirm the account for the default email
      And I sign in with default info
      And I go to My Applications
      And I click the Continue Application button
      Then I should see my name and DOB
      When I submit the page
      Then I should see my contact info
      When I submit the page
      And I confirm my address
      Then I should see my alternate contact
      When I submit the page
      Then I should see the name of my alternate contact
      When I submit the page
      Then I should see the info of my alternate contact
      When I submit the page
      Then I should see my household members
      When I edit the household member
      Then I should see the info of my household member
      When I submit the page
      And I indicate being done adding people


      # check all things step by step here

      And I go to the review step
      And I fill out the optional survey
      And I confirm details on the review page
      And I agree to the terms and submit
      And I go to My Applications
      And I view the application from My Applications
      Then I should see my name, DOB, email, Live in SF Preference, COP and DTHP options all displayed as expected

      # original end to test
      And I click the Save and Finish Later button
      And I fill out my account info
      And I submit the Create Account form
      And I confirm the account for the default email

    # Scenario: Logging into account (created in earlier scenario), submitting and viewing saved application
    #   Given I have a confirmed account
    #   When I sign in
    #   And I go to My Applications
    #   Then I should see my draft application with a Continue Application button
    #   # now submit the application
    #   When I click the Continue Application button
    #
    #
    #   # skip to however far the test takes you
    #   And I confirm details on the review page
    #   And I agree to the terms and submit
    #   And I view the application from My Applications
    #   Then I should see my name, DOB, email, Live in SF Preference, COP and DTHP options all displayed as expected
    #   #
    #   # NOTE: if any Scenarios are added after this one, you may have to create a "sign out" step
    #   #

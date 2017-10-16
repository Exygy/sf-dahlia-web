Feature: Short Form Application - Assisted Housing Preference
    As a web user
    I should be able to claim the Rent Burdened / Assisted Housing preference on my application
    In order to increase my chances of getting an affordable housing unit

    Scenario: Being eligible for Assisted Housing preference with a single address
      Given I go to the first page of the Test Listing application
      When I fill out the Name page as "Jane Doe"
      And I fill out the Contact page with an address (non-NRHP match) and WorkInSF
      And I confirm my address
      And I don't indicate an alternate contact
      And I indicate living with other people
      And I add another household member named "Jonny Doe" with same address as primary
      And I indicate being done adding people
      And I indicate living in public housing
      And I indicate no ADA priority
      And I indicate having vouchers
      And I fill out my income as "35000"
      And I continue past the Lottery Preferences intro
      # See page when selecting public housing
      Then I should see the Assisted Housing Preference
      # And I select Assisted Housing Preference
      # Then I should see proof uploaders for rent burden files
      # as opposed to seeing rent burden dashboard, which could be its own test...

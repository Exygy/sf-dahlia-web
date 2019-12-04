angular.module('dahlia.components')
.component 'applicationSummary',
  templateUrl: 'short-form/components/application-summary.html'
  bindings:
    alternateContact: '<'
    applicant: '<'
    application: '<'
    householdMembers: '<'
    isRental: '<'
    isSale: '<'
    listing: '<'
    preferences: '<'
  controller: [
    '$filter', '$state', '$translate', 'LendingInstitutionService', 'ShortFormHelperService', 'ShortFormNavigationService',
    ($filter, $state, $translate, LendingInstitutionService, ShortFormHelperService, ShortFormNavigationService) ->
      ctrl = @

      ctrl.$onInit = ->
        appIsDraft = ctrl.application.status.toLowerCase() == 'draft'
        ctrl.atAutofillPreview =
          $state.current.name == "dahlia.short-form-application.autofill-preview"
        ctrl.atContinuePreviousDraft =
          $state.current.name == "dahlia.short-form-application.continue-previous-draft"
        ctrl.sectionsAreEditable = appIsDraft && !ctrl.atAutofillPreview && !ctrl.atContinuePreviousDraft

      ctrl.continueDraftApplicantHasUpdatedInfo = (field) ->
        current = ctrl.applicant
        old = ctrl.application.overwrittenApplicantInfo
        if field == 'name'
          fields = ['firstName', 'middleName', 'lastName']
          !_.isEqual(_.pick(current, fields), _.pick(old, fields))
        else if field == 'dob'
          currentDOB = "#{current.dob_day}/#{current.dob_month}/#{current.dob_year}"
          oldDOB = "#{old.dob_day}/#{old.dob_month}/#{old.dob_year}"
          currentDOB != oldDOB

      ctrl.preapprovalLetterAttached = ->
        $translate.instant('label.file_attached', {file: $translate.instant('label.preapproval_letter')})
      ctrl.verificationLetterAttached = ->
        $translate.instant('label.file_attached', {file: $translate.instant('label.verification_letter')})

      ctrl.prioritiesSelectedExists = ->
        !_.isEmpty(ctrl.application.adaPrioritiesSelected)

      ctrl.applicationVouchersSubsidies = ->
        if ctrl.application.householdVouchersSubsidies == 'Yes'
          $translate.instant('t.yes')
        else
          $translate.instant('t.none')

      ctrl.applicationIncomeAmount = ->
        income = parseFloat(ctrl.application.householdIncome.incomeTotal)
        if ctrl.application.householdIncome.incomeTimeframe == 'per_month'
          phrase = $translate.instant('t.per_month')
        else
          phrase = $translate.instant('t.per_year')

        formatted_income = $filter('currency')(income, '$', 2)
        "#{formatted_income} #{phrase}"

      ctrl.getLendingAgentName = (agentId) ->
        LendingInstitutionService.getLendingAgentName(agentId)

      ctrl.getLendingInstitution = (agentId) ->
        LendingInstitutionService.getLendingInstitution(agentId)

      ctrl.alternateContactRelationship = ->
        if ctrl.alternateContact.alternateContactType == 'Other'
          ctrl.alternateContact.alternateContactTypeOther
        else
          ctrl.alternateContact.alternateContactType

      ctrl.getStartOfSection = (section) ->
        ShortFormNavigationService.getStartOfSection(section)

      ctrl.getStartOfHouseholdDetails = ->
        ShortFormNavigationService.getStartOfHouseholdDetails()

      ctrl.addressTranslateVariable = (address) ->
        { address: address }

      ctrl.membersTranslateVariable = (members) ->
        { user: $filter('listify')(members, "firstName")}

      ctrl.priority_options = ShortFormHelperService.priority_options

      return ctrl
  ]

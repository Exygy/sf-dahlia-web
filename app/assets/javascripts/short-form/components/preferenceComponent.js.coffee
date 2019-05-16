angular.module('dahlia.components')
.component 'preference',
  bindings:
    preference: '@'
    application: '<'
    hasProof: '<'
    hasCertificate: '<'
    title: '@'
    translatedDescription: '@'
    customDescription: '@'
    translatedShortDescription: '@'
    proofOptionLabel: '@'
    buttonLabel: '@'
    proofType: '@'
    marginBottom: '<'
    required: '&'
  templateUrl: 'short-form/components/preference-component.html'

  controller:
    ['ShortFormApplicationService', 'ShortFormHelperService', '$translate',
    (ShortFormApplicationService, ShortFormHelperService, $translate) ->
      ctrl = @
      @inputInvalid = (fieldName) ->
        ShortFormApplicationService.inputInvalid(fieldName)

      @eligibleMembers = []
      @memberSelectorLabel = ''

      @initVariables = =>
        console.log('initializing variables')
        @buttonLabel ?= $translate.instant('LABEL.UPLOAD_PROOF_OF_PREFERENCE')
        prefs = @application.preferences
        if @hasProof
          @memberSelectorLabel = $translate.instant('LABEL.APPLICANT_PREFERENCES_DOCUMENT_NAME')
          prefs.documents[@preference] ?= {}
          @proofDocument = prefs.documents[@preference]
        else
          @memberSelectorLabel = $translate.instant('LABEL.APPLICANT_PREFERENCES_HOUSEHOLD_MEMBER')
        @eligibleMembers = ShortFormApplicationService.eligibleMembers(@preference)
        @proofOptions = ShortFormHelperService.proofOptions(@preference)

      @resetPreference = =>
        console.log('preference true or false',@application.preferences[@preference])
        if !@application.preferences[@preference]
          # unchecking the box
          ShortFormApplicationService.cancelPreference(@preference)
        else
          # checking the box
          ShortFormApplicationService.cancelOptOut(@preference)

      @onChange = =>
        console.log('changing the buttons')
        @resetPreference()

      @initVariables()

      return ctrl

  ]

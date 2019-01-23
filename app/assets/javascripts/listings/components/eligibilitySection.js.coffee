angular.module('dahlia.components')
.component 'eligibilitySection',
  templateUrl: 'listings/components/eligibility-section.html'
  require:
    parent: '^listingContainer'
  controller: [
    '$translate', 'ListingService', 'ListingHelperService', 'ListingPreferencesService', 'ListingUnitService',
    ($translate, ListingService, ListingHelperService, ListingPreferencesService, ListingUnitService) ->
      ctrl = @

      @loading = ListingPreferencesService.loading
      @error = ListingPreferencesService.error

      @occupancy = (unitSummary) ->
        return '1' if unitSummary.maxOccupancy == 1
        unitSummary.minOccupancy + '-' + unitSummary.maxOccupancy

      @occupancyLabel = (maxOccupancy) ->
        return $translate.instant('LISTINGS.PERSON') if maxOccupancy == 1
        $translate.instant('LISTINGS.PEOPLE')

      @showAMItoggler = ->
        return false if _.isEmpty(ListingService.AMICharts)
        amiLevel = _.last(ListingService.AMICharts)
        lastHouseholdIncomeLevel = ListingService.occupancyIncomeLevels(this.parent.listing, amiLevel)
        maxNumOfHousehold = _.max(_.map(lastHouseholdIncomeLevel, 'numOfHousehold'))
        maxNumOfHousehold > ListingService.householdAMIChartCutoff()

      @hasMultipleAMICharts = ->
        ListingService.AMICharts.length > 1

      @listingHasPreferences = ->
        this.parent.listing.preferences && this.parent.listing.preferences.length > 0

      @listingHasOnlySROUnits = ->
        ListingUnitService.listingHasOnlySROUnits(this.parent.listing)

      @getListingPreferences = ->
        ListingPreferencesService.getListingPreferences(this.parent.listing)

      @listingHasPriorityUnits = ->
        ListingUnitService.listingHasPriorityUnits(this.parent.listing)

      @priorityLabel = (priority, modifier) ->
        ListingHelperService.priorityLabel(priority, modifier)

      @occupancyIncomeLevels = (amiLevel) ->
        ListingService.occupancyIncomeLevels(this.parent.listing, amiLevel)

      @householdAMIChartCutoff = ->
        ListingService.householdAMIChartCutoff()

      @incomeForHouseholdSize = (amiChart, householdIncomeLevel) ->
        ListingService.incomeForHouseholdSize(amiChart, householdIncomeLevel)

      return ctrl
  ]

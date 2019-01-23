############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingEligibilityService = ($localStorage, ListingHelperService, ListingUnitService) ->
  Service = {}
  Service.eligibility_filter_defaults =
    'household_size': ''
    'income_timeframe': ''
    'income_total': ''
    'include_children_under_6': false
    'children_under_6': ''

  $localStorage.eligibility_filters ?= angular.copy(Service.eligibility_filter_defaults)
  Service.eligibility_filters = $localStorage.eligibility_filters

  Service.setEligibilityFilters = (filters) ->
    angular.copy(filters, Service.eligibility_filters)

  Service.resetEligibilityFilters = ->
    angular.copy(Service.eligibility_filter_defaults, Service.eligibility_filters)

  Service.hasEligibilityFilters = ->
    hasIncome = Service.eligibility_filters.income_total >= 0 ? true : false
    !! (hasIncome &&
        Service.eligibility_filters.income_timeframe &&
        Service.eligibility_filters.household_size)

  Service.eligibilityYearlyIncome = ->
    if Service.eligibility_filters.income_timeframe == 'per_month'
      parseFloat(Service.eligibility_filters.income_total) * 12
    else
      parseFloat(Service.eligibility_filters.income_total)

  Service.occupancyMinMax = (listing) ->
    minMax = [1, 1]
    if listing.unitSummary
      min = _.min(_.map(listing.unitSummary, 'minOccupancy')) || 1
      max = _.max(_.map(listing.unitSummary, 'maxOccupancy')) || 2
      minMax = [min, max]
    return minMax

  Service.occupancyIncomeLevels = (listing, amiLevel) ->
    return [] unless amiLevel
    occupancyMinMax = Service.occupancyMinMax(listing)
    min = occupancyMinMax[0]
    # We add '+ 2' for 2 children under 6 as part of householdsize but not occupancy
    max = occupancyMinMax[1] + 2
    # TO DO: Hardcoded Temp fix, take this and replace with long term solution
    if (
      ListingHelperService.listingIs('Merry Go Round Shared Housing', listing) ||
      ListingHelperService.listingIs('1335 Folsom Street', listing) ||
      ListingHelperService.listingIs('750 Harrison Street', listing)
    )
      max = 2
    else if ListingUnitService.listingHasOnlySROUnits(listing)
      max = 1
    _.filter amiLevel.values, (value) ->
      # where numOfHousehold >= min && <= max
      value.numOfHousehold >= min && value.numOfHousehold <= max

  Service.incomeForHouseholdSize = (amiChart, householdIncomeLevel) ->
    incomeLevel = _.find amiChart.values, (value) ->
      value.numOfHousehold == householdIncomeLevel.numOfHousehold
    return unless incomeLevel
    incomeLevel.amount

  Service.householdAMIChartCutoff = (listing) ->
    # TO DO: Hardcoded Temp fix, take this and replace with long term solution
    if(
      ListingHelperService.listingIs('Merry Go Round Shared Housing', listing) ||
      ListingHelperService.listingIs('1335 Folsom Street', listing) ||
      ListingHelperService.listingIs('750 Harrison Street', listing)
    )
      return 2
    else if ListingUnitService.listingHasOnlySROUnits(listing)
      return 1
    occupancyMinMax = Service.occupancyMinMax(listing)
    max = occupancyMinMax[1]
    # cutoff at 2x the num of bedrooms
    Math.floor(max/2) * 2

  return Service


############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingEligibilityService.$inject = ['$localStorage', 'ListingHelperService', 'ListingUnitService']

angular
  .module('dahlia.services')
  .service('ListingEligibilityService', ListingEligibilityService)

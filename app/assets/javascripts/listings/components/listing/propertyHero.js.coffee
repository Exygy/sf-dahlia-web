angular.module('dahlia.components')
.component 'propertyHero',
  templateUrl: 'listings/components/listing/property-hero.html'
  require:
    parent: '^listingContainer'
  controller: [
    'ListingDataService', 'ListingUnitService', '$filter', '$sce', '$timeout', '$translate', '$window',
    (ListingDataService, ListingUnitService, $filter, $sce, $timeout, $translate, $window) ->
      ctrl = @

      @isLoadingUnits = () ->
        ListingUnitService.loading.units

      @hasUnitsError = () ->
        ListingUnitService.error.units

      @adjustCarouselHeight = (elem) ->
        $timeout ->
          ctrl.carouselHeight = elem[0].offsetHeight
        , 0, false

      @carouselHeight = 300

      @reservedUnitIcons = [
        $sce.trustAsResourceUrl('#i-star')
        $sce.trustAsResourceUrl('#i-cross')
        $sce.trustAsResourceUrl('#i-oval')
        $sce.trustAsResourceUrl('#i-polygon')
      ]

      @listingImages = (listing) ->
        # TODO: update when we are getting multiple images from Salesforce
        # right now it's just an array of one
        [listing.imageURL]

      @reservedDescriptorIcon = (listing, descriptor) ->
        index = _.findIndex(listing.reservedDescriptor, ['name', descriptor])
        @reservedUnitIcons[index]

      @getCurrencyString = (v) -> $filter('currency')(v, '$', 0)

      @getCurrencyRange = (min, max) ->
        if min? && max? && min < max
          $translate.instant('listings.stats.currency_range', {
            currencyMinValue: @getCurrencyString(min)
            currencyMaxValue: @getCurrencyString(max)
          })
        else if min?
          @getCurrencyString(min)
        else if max?
          @getCurrencyString(max)
        else
          ""

      @getIncomeRangeFromUnitGroup = (unitGroup) -> @getCurrencyRange(unitGroup.minIncome, unitGroup.maxIncome)
      @getIncomeRangeFromPriceGroup = (priceGroup) -> @getCurrencyRange(priceGroup.minIncome, priceGroup.maxIncome)

      @getHouseholdTextFromOccupancy = (occupancy) ->
        if occupancy == '1'
          $translate.instant('listings.stats.num_in_household_singular')
        else
          $translate.instant('listings.stats.num_in_household_plural')


      @numAvailableString = (priceGroup) -> priceGroup.occupancy + " " + $translate.instant('listings.stats.available')

      occupanciesToIsExpanded = {}

      @isExpanded = (priceGroup) -> !!occupanciesToIsExpanded[priceGroup.occupancy]
      @toggleExpanded = (priceGroup) ->
        occupanciesToIsExpanded[priceGroup.occupancy] =
          if (occupanciesToIsExpanded[priceGroup.occupancy] == undefined)
            true
          else
            !occupanciesToIsExpanded[priceGroup.occupancy]

      @labelForIncomeLevelTable = (occupancy, incomeLevelString) =>
        $translate.instant('listings.stats.table_label', {
          numInHouseholdString: "#{occupancy} #{@getHouseholdTextFromOccupancy(occupancy)}",
          amiPercentString: incomeLevelString
        })

      @unitTypeId = (unitGroup, incomeLevelIndex, priceGroupIndex) =>
        return "unit_type_occupancy_#{unitGroupIndex}__income_#{incomelevel}__price_group_#{priceGroupIndex}"

      return ctrl
  ]

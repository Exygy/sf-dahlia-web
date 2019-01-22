do ->
  'use strict'
  describe 'Listing Container Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    listing = undefined
    yesterday = new Date()
    yesterday.setDate(yesterday.getDate() - 1)
    tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    fakeListingService = {}
    $translate =
      instant: ->
    fakeSharedService = {}
    fakeShortFormApplicationService =
      getLanguageCode: jasmine.createSpy()
    fakeAnalyticsService = {}
    fakeListings = getJSONFixture('listings-api-index.json').listings
    fakeListing = getJSONFixture('listings-api-show.json').listing
    fakeListingFavorites = {}
    eligibilityFilterDefaults =
      'household_size': ''
      'income_timeframe': ''
      'income_total': ''
      'include_children_under_6': false
      'children_under_6': ''
    fakeListingEligibilityService = {
      eligibility_filter_defaults: eligibilityFilterDefaults
      eligibility_filters: eligibilityFilterDefaults
      resetEligibilityFilters: jasmine.createSpy()
    }
    hasFilters = false
    fakeListingService =
      listings: fakeListings
      openListings: []
      openMatchListings: []
      openNotMatchListings: []
      closedListings: []
      lotteryResultsListings: []
      listing: fakeListing
      favorites: fakeListingFavorites
      AMICharts: []
      lotteryPreferences: []
      formatLotteryNumber: () -> null
      getLotteryRanking: () -> null
      hasEligibilityFilters: () -> null
      stubFeatures: () -> null
      listingIs: () -> null
      loading: {}
      toggleFavoriteListing: jasmine.createSpy()
      isFavorited: jasmine.createSpy()
      formattedAddress: jasmine.createSpy()
      listingHasPriorityUnits: jasmine.createSpy()
      listingHasReservedUnits: jasmine.createSpy()
      listingHasOnlySROUnits: jasmine.createSpy()
      getListingAMI: jasmine.createSpy()
      getListingUnits: jasmine.createSpy()
      listingIsBMR: jasmine.createSpy()
      listingHasSROUnits: jasmine.createSpy()
      listingIsReservedCommunity: jasmine.createSpy()
    fakeListingHelperService =
      priorityLabel: jasmine.createSpy()
      formattedAddress: jasmine.createSpy()
      reservedLabel: jasmine.createSpy()
      listingIs: jasmine.createSpy()
      listingIsFirstComeFirstServe: jasmine.createSpy()
      listingIsOpen: jasmine.createSpy()
    fakeListingLotteryService =
      getLotteryBuckets: ->
      listingHasLotteryResults: ->
      openLotteryResultsModal: jasmine.createSpy()

    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        ListingService: fakeListingService
        $translate: $translate
        ListingHelperService: fakeListingHelperService
        SharedService: fakeSharedService
        ListingEligibilityService: fakeListingEligibilityService
      }
    )

    describe 'listingContainer', ->
      beforeEach ->
        ctrl = $componentController 'listingContainer', locals

      describe 'initiates ctrl default values', ->
        it 'populates ctrl with array of listings', ->
          expect(ctrl.listings).toEqual fakeListings

        it 'populates ctrl with a single listing', ->
          expect(ctrl.listing).toEqual fakeListing

        it 'populates ctrl with AMICharts', ->
          expect(ctrl.AMICharts).toBeDefined()

        it 'populates ctrl with favorites', ->
          expect(ctrl.favorites).toEqual fakeListingFavorites

        it 'populates ctrl with openListings', ->
          expect(ctrl.openListings).toBeDefined()

        it 'populates ctrl with openMatchListings', ->
          expect(ctrl.openMatchListings).toBeDefined()

        it 'populates ctrl with openNotMatchListings', ->
          expect(ctrl.openNotMatchListings).toBeDefined()

        it 'populates ctrl with closedListings', ->
          expect(ctrl.closedListings).toBeDefined()

        it 'populates ctrl with lotteryResultsListings', ->
          expect(ctrl.lotteryResultsListings).toBeDefined()

      describe '$ctrl.isOpenMatchListing', ->
        describe "when the given listing is in the controller's list of open match listings", ->
          it 'returns true',->
            ctrl.openMatchListings = [fakeListing]
            expect(ctrl.isOpenMatchListing(fakeListing)).toEqual true
        describe "when the given listing is not in the controller's list of open match listings", ->
          it 'returns false',->
            ctrl.openMatchListings = []
            expect(ctrl.isOpenMatchListing(fakeListing)).toEqual false

      describe '$ctrl.isFavorited', ->
        it 'calls ListingService.isFavorited with the given listing ID', ->
          fakeListingId = 'asdf1234'
          ctrl.isFavorited(fakeListingId)
          expect(fakeListingService.isFavorited).toHaveBeenCalledWith(fakeListingId)

      describe '$ctrl.reservedLabel', ->
        it 'calls ListingHelperService.reservedLabel', ->
          ctrl.reservedLabel()
          expect(fakeListingHelperService.reservedLabel).toHaveBeenCalled()

      describe '$ctrl.getListingAMI', ->
        it 'calls ListingService.getListingAMI', ->
          ctrl.getListingAMI()
          expect(fakeListingService.getListingAMI).toHaveBeenCalled()

      describe '$ctrl.listingIsReservedCommunity', ->
        it 'calls ListingService.listingIsReservedCommunity', ->
          ctrl.listingIsReservedCommunity()
          expect(fakeListingService.listingIsReservedCommunity).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.listingIs', ->
        it 'calls ListingHelperService.listingIs with the given name and listing', ->
          name = 'fake'
          ctrl.listingIs(name, fakeListing)
          expect(fakeListingHelperService.listingIs).toHaveBeenCalledWith(name, fakeListing)

      describe '$ctrl.listingHasReservedUnits', ->
        it "calls ListingService.listingHasReservedUnits with the controller's listing", ->
          ctrl.listingHasReservedUnits()
          expect(fakeListingService.listingHasReservedUnits).toHaveBeenCalledWith(ctrl.listing)

      describe '$ctrl.listingIsFirstComeFirstServe', ->
        it 'calls ListingHelperService.listingIsFirstComeFirstServe', ->
          ctrl.listingIsFirstComeFirstServe()
          expect(fakeListingHelperService.listingIsFirstComeFirstServe).toHaveBeenCalledWith(fakeListing)

      describe '$ctrl.toggleFavoriteListing', ->
        it 'expects ListingService.function to be called', ->
          ctrl.toggleFavoriteListing 1
          expect(fakeListingService.toggleFavoriteListing).toHaveBeenCalled()

      describe '$ctrl.hasEligibilityFilters', ->
        it 'expects fakeListingEligibilityService.hasEligibilityFilters to be called', ->
          fakeListingEligibilityService.hasEligibilityFilters = jasmine.createSpy()
          ctrl.hasEligibilityFilters()
          expect(fakeListingEligibilityService.hasEligibilityFilters).toHaveBeenCalled()

      describe '$ctrl.listingApplicationClosed', ->
        it 'expects ListingHelperService.listingIsOpen to be called', ->
          ctrl.listingApplicationClosed(fakeListing)
          expect(fakeListingHelperService.listingIsOpen).toHaveBeenCalled()

      describe '$ctrl.lotteryDateVenueAvailable', ->
        beforeEach ->
          listing = fakeListing
          listing.Lottery_Date = new Date()
          listing.Lottery_Venue = "Exygy"
          listing.Lottery_Street_Address = "123 Main St., San Francisco"

        describe 'listing lottery date, venue and lottery address all have values', ->
          it 'returns true', ->
            expect(ctrl.lotteryDateVenueAvailable(listing)).toEqual true

        describe 'listing lottery date missing', ->
          it 'returns false', ->
            listing.Lottery_Date = undefined
            expect(ctrl.lotteryDateVenueAvailable(listing)).toEqual false

        describe 'listing venue missing', ->
          it 'returns false', ->
            listing.Lottery_Venue = undefined
            expect(ctrl.lotteryDateVenueAvailable(listing)).toEqual false

        describe 'listing lottery address missing', ->
          it 'returns false', ->
            listing.Lottery_Street_Address = undefined
            expect(ctrl.lotteryDateVenueAvailable(listing)).toEqual false

      describe '$ctrl.formattedBuildingAddress', ->
        it 'expects ListingService.function to be called', ->
          display = 'full'
          ctrl.formattedBuildingAddress(fakeListing, display)
          expect(fakeListingHelperService.formattedAddress).toHaveBeenCalledWith(fakeListing, 'Building', display)

      describe '$ctrl.getListingUnits', ->
        it 'calls ListingService.getListingUnits', ->
          ctrl.getListingUnits()
          expect(fakeListingService.getListingUnits).toHaveBeenCalled()

      describe '$ctrl.formattedLeasingAgentAddress', ->
        it 'calls ListingHelperService.formattedAddress', ->
          ctrl.formattedLeasingAgentAddress(fakeListing)
          expect(fakeListingHelperService.formattedAddress).toHaveBeenCalledWith(fakeListing, 'Leasing_Agent')

      describe '$ctrl.listingHasSROUnits', ->
        it 'calls ListingService.listingHasSROUnits', ->
          ctrl.listingHasSROUnits()
          expect(fakeListingService.listingHasSROUnits).toHaveBeenCalled()

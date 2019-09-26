angular.module('dahlia.components')
.component 'listingContainer',
  transclude: true
  templateUrl: 'listings/components/listing-container.html'
  controller: ['$translate', '$window', 'ListingDataService', 'ListingEligibilityService', 'ListingIdentityService',
  'ListingUnitService', 'SharedService',
  ($translate, $window, ListingDataService, ListingEligibilityService, ListingIdentityService, ListingUnitService, SharedService) ->
    ctrl = @
    # TODO: remove Shared Service once we create a Shared Container
    @listingEmailAlertUrl = "http://eepurl.com/dkBd2n"
    @assetPaths = SharedService.assetPaths
    @listing = ListingDataService.listing
    @listings = ListingDataService.listings
    @loading  = ListingDataService.loading
    @error = ListingDataService.error
    @toggleStates = ListingDataService.toggleStates
    @AMICharts = ListingDataService.AMICharts
    @favorites = ListingDataService.favorites

    @openListings = ListingDataService.openListings
    @openMatchListings = ListingDataService.openMatchListings
    @openNotMatchListings = ListingDataService.openNotMatchListings
    @closedListings = ListingDataService.closedListings
    @lotteryResultsListings = ListingDataService.lotteryResultsListings
    @showSaleListings = $window.env.showSaleListings == 'true'

    @isRental = (listing) ->
      ListingIdentityService.isRental(listing)

    @isSale = (listing) ->
      ListingIdentityService.isSale(listing)

    @hasSaleAndRentalFavorited = (listings) ->
      favoritedListings = @filterByFavorites listings
      areSaleListings = (@isSale listing for listing in favoritedListings)
      (_.some areSaleListings) && !(_.every areSaleListings)

    @isOpenMatchListing = (listing) ->
      @openMatchListings.indexOf(listing) > -1

    @isFavorited = (listingId) ->
      ListingDataService.isFavorited(listingId)

    @filterByFavorites = (listings) ->
      (listing for listing in listings when @isFavorited listing.Id)

    @reservedLabel = (listing, type, modifier) ->
      ListingDataService.reservedLabel(listing, type, modifier)

    @getListingAMI =(listing) ->
      ListingDataService.getListingAMI(listing)

    @listingIsReservedCommunity = (listing) ->
      !! listing.Reserved_community_type

    @listingIs = (name, listing) ->
      ListingIdentityService.listingIs(name, listing)

    @listingHasReservedUnits = (listing) ->
      ListingUnitService.listingHasReservedUnits(listing)

    @listingApplicationClosed = (listing) ->
      !ListingIdentityService.isOpen(listing)

    @formattedBuildingAddress = (listing, display) ->
      ListingDataService.formattedAddress(listing, 'Building', display)

    @formattedLeasingAgentAddress = (listing) ->
      ListingDataService.formattedAddress(listing, 'Leasing_Agent')

    @toggleFavoriteListing = (listingId) ->
      ListingDataService.toggleFavoriteListing(listingId)

    @getListingUnits = (listing) ->
      ListingUnitService.getListingUnits(listing)

    @listingHasSROUnits = (listing) ->
      ListingUnitService.listingHasSROUnits(listing)

    @hasEligibilityFilters = ->
      ListingEligibilityService.hasEligibilityFilters()

    @lotteryDateVenueAvailable = (listing) ->
      (listing.Lottery_Date != undefined &&
        listing.Lottery_Venue != undefined && listing.Lottery_Street_Address != undefined)

    @agentInfoAvailable = (listing) ->
      listing.Leasing_Agent_Phone || listing.Leasing_Agent_Email || listing.Leasing_Agent_Street

    @featuresCaption = (listing) ->
      if ListingIdentityService.isSale(listing)
        $translate.instant("listings.features.sale_subheader")
      else
        $translate.instant("listings.features.rent_subheader")

    return ctrl
  ]

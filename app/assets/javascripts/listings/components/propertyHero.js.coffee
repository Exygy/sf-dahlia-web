angular.module('dahlia.components')
.component 'propertyHero',
  templateUrl: 'listings/components/property-hero.html'
  require:
    parent: '^listingContainer'
  controller: [
    'ListingDataService', '$sce', '$timeout', '$window',
    (ListingDataService, $sce, $timeout, $window) ->
      ctrl = @

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

      @hasMultipleAMIUnits = ->
        _.keys(this.parent.listing.groupedUnits).length > 1

      @reservedDescriptorIcon = (listing, descriptor) ->
        index = _.findIndex(listing.reservedDescriptor, ['name', descriptor])
        @reservedUnitIcons[index]

      @groupHasUnitsWithParking = (unitGroups) ->
        for group in unitGroups
          if group.Price_With_Parking
            return true
        false

      @groupHasUnitsWithoutParking = (unitGroups) ->
        for group in unitGroups
          if group.Price_Without_Parking
            return true
        false

      return ctrl
  ]

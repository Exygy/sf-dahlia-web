do ->
  'use strict'
  describe 'Lottery Info Section Component', ->
    $componentController = undefined
    ctrl = undefined
    locals = undefined
    fakeListings = getJSONFixture('listings-api-index.json').listings
    fakeListing = getJSONFixture('listings-api-show.json').listing
    fakeParent = {
      listing: fakeListing
    }
    fakeListingService =
      listings: fakeListings
      listingHasLotteryResults: jasmine.createSpy()
      openLotteryResultsModal: jasmine.createSpy()
    fakeListingLotteryService =
      listingHasLotteryBuckets: ->

    beforeEach module('dahlia.components')
    beforeEach inject((_$componentController_) ->
      $componentController = _$componentController_
      locals = {
        ListingService: fakeListingService
        ListingLotteryService: fakeListingLotteryService
      }
    )

    describe 'lotteryInfoSection', ->
      beforeEach ->
        ctrl = $componentController 'lotteryInfoSection', locals, {parent: fakeParent}

      describe 'listingHasLotteryResults', ->
        it 'calls ListingService.listingHasLotteryResults', ->
          ctrl.listingHasLotteryResults()
          expect(fakeListingService.listingHasLotteryResults).toHaveBeenCalled()

      describe 'openLotteryResultsModal', ->
        it 'expect ListingService.openLotteryResultsModal to be called', ->
          ctrl.openLotteryResultsModal()
          expect(fakeListingService.openLotteryResultsModal).toHaveBeenCalled()

      describe '$ctrl.showLotteryResultsModalButton', ->
        it 'calls ListingLotteryService.listingHasLotteryBuckets', ->
          spyOn(fakeListingLotteryService, 'listingHasLotteryBuckets')
          ctrl.showLotteryResultsModalButton()
          expect(fakeListingLotteryService.listingHasLotteryBuckets).toHaveBeenCalled()

      describe '$ctrl.showDownloadLotteryResultsButton', ->
        it 'calls ListingLotteryService.listingHasLotteryBuckets', ->
          spyOn(fakeListingLotteryService, 'listingHasLotteryBuckets')
          ctrl.showDownloadLotteryResultsButton()
          expect(fakeListingLotteryService.listingHasLotteryBuckets).toHaveBeenCalled()
        it 'returns false if listing has buckets', ->
          spyOn(fakeListingLotteryService, 'listingHasLotteryBuckets').and.returnValue(true)
          expect(ctrl.showDownloadLotteryResultsButton()).toEqual false
        it 'returns true if listing is missing buckets', ->
          spyOn(fakeListingLotteryService, 'listingHasLotteryBuckets').and.returnValue(false)
          expect(ctrl.showDownloadLotteryResultsButton()).toEqual true

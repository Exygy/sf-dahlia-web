############################################################################################
####################################### SERVICE ############################################
############################################################################################

ListingService = (
  $http, $localStorage, $q, $state, $translate, $timeout,
  ExternalTranslateService, ListingConstantsService, ListingHelperService,
  ListingEligibilityService, ListingLotteryService, ListingUnitService, SharedService) ->
  Service = {}
  MAINTENANCE_LISTINGS = [] unless MAINTENANCE_LISTINGS
  Service.listing = {}
  Service.listings = []
  Service.openListings = []
  Service.openMatchListings = []
  Service.openNotMatchListings = []
  Service.closedListings = []
  Service.lotteryResultsListings = []
  # these get loaded after the listing is loaded
  Service.AMICharts = []
  Service.loading = {}
  Service.error = {}
  Service.toggleStates = {}

  Service.preferenceMap = ListingConstantsService.preferenceMap

  Service.listingDownloadURLs = []
  $localStorage.favorites ?= []
  Service.favorites = $localStorage.favorites

  Service.getFavoriteListings = () ->
    Service.getListingsByIds(Service.favorites, true)

  # Service.checkFavorites makes sure that Service.listings contains our favorited listings
  # if not, it means the listing doesn't exist and we should remove it from favorites
  Service.checkFavorites = () ->
    listing_ids = []
    Service.listings.forEach (listing) -> listing_ids.push(listing['Id'])
    Service.favorites.forEach (favorite_id) ->
      if listing_ids.indexOf(favorite_id) == -1
        Service.toggleFavoriteListing(favorite_id)

  Service.toggleFavoriteListing = (listing_id) ->
    # toggle the value for listing_id
    index = Service.favorites.indexOf(listing_id)
    if index == -1
      # add the favorite
      Service.favorites.push(listing_id)
    else
      # remove the favorite
      Service.favorites.splice(index, 1)

  Service.isFavorited = (listing_id) ->
    Service.favorites.indexOf(listing_id) > -1

  Service.occupancyMinMax = (listing) ->
    minMax = [1, 1]
    if listing.unitSummary
      min = _.min(_.map(listing.unitSummary, 'minOccupancy')) || 1
      max = _.max(_.map(listing.unitSummary, 'maxOccupancy')) || 2
      minMax = [min, max]
    return minMax

  Service.hasPreference = (preference, listing = Service.listing) ->
    preferenceNames = _.map(listing.preferences, (pref) -> pref.preferenceName)
    # look up the full name of the preference (i.e. "workInSf" -> "Live/Work Preference")
    preferenceName = Service.preferenceMap[preference]
    return _.includes(preferenceNames, preferenceName)

  Service.getPreference = (preference) ->
    # looks up full preference object via the short name e.g. 'liveInSf'
    preferenceName = Service.preferenceMap[preference]
    _.find(Service.listing.preferences, { preferenceName: preferenceName })

  Service.getPreferenceById = (listingPreferenceID) ->
    _.find(Service.listing.preferences, { listingPreferenceID: listingPreferenceID })

  Service.maxIncomeLevelsFor = (listing, ami) ->
    occupancyMinMax = Service.occupancyMinMax(listing)
    incomeLevels = []
    ami.forEach (amiLevel) ->
      occupancy = parseInt(amiLevel.numOfHousehold)
      # only grab the incomeLevels that fit within our listing's occupancyMinMax
      # + we add 2 more to account for potential childrenUnder6
      min = occupancyMinMax[0]
      max = occupancyMinMax[1] + 2
      if occupancy >= min && occupancy <= max
        incomeLevels.push({
          occupancy: occupancy,
          yearly: parseFloat(amiLevel.amount),
          monthly: Math.floor(parseFloat(amiLevel.amount) / 12.0)
        })
    return incomeLevels

  Service.sortByDate = (sessions) ->
    # used for sorting Open_Houses and Information_Sessions
    _.sortBy sessions, (session) ->
      moment("#{session.Date} #{session.Start_Time}", 'YYYY-MM-DD h:mmA')

  ###################################### Salesforce API Calls ###################################

  Service.getListing = (_id, forceRecache = false, retranslate = false) ->
    _id = Service.mapSlugToId(_id)

    if Service.listing && Service.listing.Id == _id
      # return a resolved promise if we already have the listing
      return $q.when(Service.listing)
    Service.resetListingData()

    deferred = $q.defer()
    httpConfig = { etagCache: true }
    httpConfig.params = { force: true } if forceRecache
    $http.get("/api/v1/listings/#{_id}.json", httpConfig)
    .success(
      Service.getListingResponse(deferred, retranslate)
    ).cached(
      Service.getListingResponse(deferred, retranslate)
    ).error( (data, status, headers, config) ->
      deferred.reject(data)
    )
    return deferred.promise

  # Remove the previous listing and all it's associated data
  Service.resetListingData = () ->
    angular.copy({}, Service.listing)
    angular.copy([], Service.AMICharts)
    angular.copy([], Service.listingDownloadURLs)
    ListingLotteryService.resetData()

  Service.getListingResponse = (deferred, retranslate = false) ->
    (data, status, headers, config, itemCache) ->
      itemCache.set(data) unless status == 'cached'
      deferred.resolve()
      if !data || !data.listing
        return
      angular.copy(data.listing, Service.listing)
      # fallback for fixing the layout when a listing is missing an image
      Service.listing.imageURL ?= 'https://unsplash.it/g/780/438'
      # create a combined unitSummary
      unless Service.listing.unitSummary
        Service.listing.unitSummary = ListingUnitService.combineUnitSummaries(Service.listing)
      # On listing and listings pages, we are experiencing an issue where
      # where the Google translation will try to keep up with digest re-calcs
      # happening during page load and will get tripped up and fail, leaving
      # the page untranslated. This quick fix runs the Google Translation
      # again to cover for a possible earlier failed translate.
      # TODO: Remove this quick fix for translation issues on listing pages
      # and replace with a real fix based on actual digest timing.
      $timeout(ExternalTranslateService.translatePageContent, 0, false) if retranslate
      Service.toggleStates[Service.listing.Id] ?= {}

  Service.getListings = (opts = {}) ->
    # check for eligibility options being set in the session
    if opts.checkEligibility && ListingEligibilityService.hasEligibilityFilters()
      return Service.getListingsWithEligibility()
    deferred = $q.defer()
    $http.get("/api/v1/listings.json", {
      etagCache: true
    }).success(
      Service.getListingsResponse(deferred, opts.retranslate)
    ).cached(
      Service.getListingsResponse(deferred, opts.retranslate)
    ).error((data, status, headers, config) ->
      deferred.reject(data)
    )
    return deferred.promise

  Service.getListingsResponse = (deferred, retranslate = false) ->
    (data, status, headers, config, itemCache) ->
      itemCache.set(data) unless status == 'cached'
      listings = if data and data.listings then data.listings else []
      listings = Service.cleanListings(listings)
      Service.groupListings(listings)
      # On listing and listings pages, we are experiencing an issue where
      # where the Google translation will try to keep up with digest re-calcs
      # happening during page load and will get tripped up and fail, leaving
      # the page untranslated. This quick fix runs the Google Translation
      # again to cover for a possible earlier failed translate.
      # TODO: Remove this quick fix for translation issues on listing pages
      # and replace with a real fix based on actual digest timing.
      $timeout(ExternalTranslateService.translatePageContent, 0, false) if retranslate
      deferred.resolve()

  Service.getListingsWithEligibility = ->
    params =
      householdsize: ListingEligibilityService.eligibility_filters.household_size
      incomelevel: ListingEligibilityService.eligibilityYearlyIncome()
      includeChildrenUnder6: ListingEligibilityService.eligibility_filters.include_children_under_6
      childrenUnder6: ListingEligibilityService.eligibility_filters.children_under_6
    deferred = $q.defer()
    $http.get("/api/v1/listings/eligibility.json?#{SharedService.toQueryString(params)}",
      { etagCache: true }
    ).success(
      Service.getListingsWithEligibilityResponse(deferred)
    ).cached(
      Service.getListingsWithEligibilityResponse(deferred)
    ).error( (data, status, headers, config) ->
      deferred.reject(data)
    )
    return deferred.promise

  Service.getListingsWithEligibilityResponse = (deferred) ->
    (data, status, headers, config, itemCache) ->
      itemCache.set(data) unless status == 'cached'
      listings = (if data and data.listings then data.listings else [])
      listings = Service.cleanListings(listings)
      Service.groupListings(listings)
      deferred.resolve()

  Service.cleanListings = (listings) ->
    _.map listings, (listing) ->
      # fallback for fixing the layout when a listing is missing an image
      listing.imageURL ?= 'https://unsplash.it/g/780/438'
    _.filter listings, (listing) ->
      !_.includes(MAINTENANCE_LISTINGS, listing.Id)

  Service.groupListings = (listings) ->
    openListings = []
    openMatchListings = []
    openNotMatchListings = []
    closedListings = []
    lotteryResultsListings = []

    listings.forEach (listing) ->
      if ListingHelperService.isOpen(listing)
        # All Open Listings Array
        openListings.push(listing)
        if listing.Does_Match
          openMatchListings.push(listing)
        else
          openNotMatchListings.push(listing)
      else
        if ListingLotteryService.lotteryIsUpcoming(listing)
          closedListings.push(listing)
        else
          lotteryResultsListings.push(listing)

    angular.copy(Service.sortListings(openListings, 'openListings'), Service.openListings)
    angular.copy(Service.sortListings(openMatchListings, 'openMatchListings'), Service.openMatchListings)
    angular.copy(Service.sortListings(openNotMatchListings, 'openNotMatchListings'), Service.openNotMatchListings)
    angular.copy(Service.sortListings(closedListings, 'closedListings'), Service.closedListings)
    angular.copy(Service.sortListings(lotteryResultsListings, 'lotteryResultsListings'), Service.lotteryResultsListings)

  Service.sortListings = (listings, type) ->
    # openListing types
    if ['openListings', 'openMatchListings', 'openNotMatchListings'].indexOf(type) > -1
      _.sortBy listings, (i) -> moment(i.Application_Due_Date)
    # closedListing types
    else if ['closedListings', 'lotteryResultsListings'].indexOf(type) > -1
      listings = _.sortBy listings, (i) ->
        # fallback to Application_Due_Date, really only for the special case of First Come First Serve
        moment(i.Lottery_Results_Date || i.Application_Due_Date)
      # lotteryResults get reversed (latest lottery results date first)
      if type == 'lotteryResultsListings' then _.reverse listings else listings

  # retrieves only the listings specified by the passed in array of ids
  Service.getListingsByIds = (ids, checkFavorites = false) ->
    angular.copy([], Service.listings)
    params = {params: {ids: ids.join(',') }}
    $http.get("/api/v1/listings.json", params).success((data, status, headers, config) ->
      listings = if data and data.listings then data.listings else []
      angular.copy(listings, Service.listings)
      Service.checkFavorites() if checkFavorites
    ).error( (data, status, headers, config) ->
      return
    )

  Service.isAcceptingOnlineApplications = (listing) ->
    return false if _.isEmpty(listing)
    return false if ListingLotteryService.lotteryComplete(listing)
    return false unless ListingHelperService.isOpen(listing)
    return listing.Accepting_Online_Applications

  Service.getListingAndCheckIfOpen = (id) ->
    deferred = $q.defer()
    Service.getListing(id).then( ->
      deferred.resolve(Service.listing)
      if _.isEmpty(Service.listing)
        # kick them out unless there's a real listing
        return $state.go('dahlia.welcome')
      else if !Service.isAcceptingOnlineApplications(Service.listing)
        # kick them back to the listing
        return $state.go('dahlia.listing', {id: id})
    ).catch( (response) ->
      deferred.reject(response)
    )
    deferred.promise

  Service.getListingAMI = ->
    angular.copy([], Service.AMICharts)
    Service.loading.ami = true
    Service.error.ami = false
    # shouldn't happen, but safe to have a guard clause
    return $q.when() unless Service.listing.chartTypes
    allChartTypes = _.sortBy(Service.listing.chartTypes, 'percent')
    data =
      'year[]': _.map(allChartTypes, 'year')
      'chartType[]': _.map(allChartTypes, 'chartType')
      'percent[]': _.map(allChartTypes, 'percent')
    $http.get('/api/v1/listings/ami.json', { params: data }).success((data, status, headers, config) ->
      if data && data.ami
        angular.copy(Service._consolidatedAMICharts(data.ami), Service.AMICharts)
      Service.loading.ami = false
    ).error( (data, status, headers, config) ->
      Service.loading.ami = false
      Service.error.ami = true
      return
    )

  Service._consolidatedAMICharts = (amiData) ->
    charts = []
    amiData.forEach (chart) ->
      # look for an existing chart at the same percentage level
      amiPercentChart = _.find charts, (c) -> c.percent == chart.percent
      if !amiPercentChart
        # only push chart if it has any values
        charts.push(chart) if chart.values.length
      else
        # if it exists, modify it with the max values
        i = 0
        amiPercentChart.values.forEach (incomeLevel) ->
          chartAmount = if chart.values[i] then chart.values[i].amount else 0
          incomeLevel.amount = Math.max(incomeLevel.amount, chartAmount)
          i++
    charts

  Service.priorityTypes = (listing) ->
    Service.collectTypes(listing, 'prioritiesDescriptor')

  Service.collectTypes = (listing, specialType) ->
    _.map listing[specialType], (descriptor) ->
      descriptor.name

  Service.getListingPreferences = (forceRecache = false) ->
    Service.loading.preferences = true
    # Reset preferences that might already exist
    angular.copy([], Service.listing.preferences)
    Service.error.preferences = false
    Service.stubListingPreferences()
    # if this listing had stubbed preferences then we can abort
    if !_.isEmpty(Service.listing.preferences)
      return $q.when(Service.listing.preferences).then ->
        Service.loading.preferences = false
    ## <--
    httpConfig = { etagCache: true }
    httpConfig.params = { force: true } if forceRecache
    $http.get("/api/v1/listings/#{Service.listing.Id}/preferences", httpConfig)
    .success((data, status, headers, config) ->
      if data && data.preferences
        Service.listing.preferences = data.preferences
        # TODO: -- REMOVE HARDCODED PREFERENCES --
        Service._extractCustomPreferences()
        Service.loading.preferences = false
    ).error( (data, status, headers, config) ->
      Service.loading.preferences = false
      Service.error.preferences = true
    )

  # TODO: Replace with `requiresProof` listing preference setting (#154784101)
  Service.hardcodeCustomProofPrefs = []

  Service._extractCustomPreferences = ->
    customPreferences = _.filter Service.listing.preferences, (listingPref) ->
      !_.invert(Service.preferenceMap)[listingPref.preferenceName]
    customProofPreferences = _.remove customPreferences, (customPref) ->
      _.includes(Service.hardcodeCustomProofPrefs, customPref.preferenceName)
    Service.listing.customPreferences = _.sortBy customPreferences, (pref) -> pref.order
    Service.listing.customProofPreferences = _.sortBy customProofPreferences, (pref) -> pref.order

  # used by My Applications -- when you load an application we also parse the attached listing data
  Service.loadListing = (listing) ->
    return if Service.listing && Service.listing.Id == listing.Id
    # TODO: won't be needed if we ever consolidate Listing_Lottery_Preferences and /preferences API
    listing.preferences = _.map listing.Listing_Lottery_Preferences, (lotteryPref) ->
      {
        listingPreferenceID: lotteryPref.Id
        preferenceName: lotteryPref.Lottery_Preference.Name
      }
    angular.copy(listing, Service.listing)

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

  Service.householdAMIChartCutoff = ->
    # TO DO: Hardcoded Temp fix, take this and replace with long term solution
    if(
      ListingHelperService.listingIs('Merry Go Round Shared Housing', Service.listing) ||
      ListingHelperService.listingIs('1335 Folsom Street', Service.listing) ||
      ListingHelperService.listingIs('750 Harrison Street', Service.listing)
    )
      return 2
    else if ListingUnitService.listingHasOnlySROUnits(Service.listing)
      return 1
    occupancyMinMax = Service.occupancyMinMax(Service.listing)
    max = occupancyMinMax[1]
    # cutoff at 2x the num of bedrooms
    Math.floor(max/2) * 2

  Service.minYearlyIncome = ->
    return if _.isEmpty(Service.AMICharts)
    incomeLevels = Service.occupancyIncomeLevels(Service.listing, _.first(Service.AMICharts))
    # get the first (lowest) income level amount
    _.first(incomeLevels).amount

  Service.incomeForHouseholdSize = (amiChart, householdIncomeLevel) ->
    incomeLevel = _.find amiChart.values, (value) ->
      value.numOfHousehold == householdIncomeLevel.numOfHousehold
    return unless incomeLevel
    incomeLevel.amount

  Service.getListingDownloadURLs = ->
    urls = angular.copy(ListingConstantsService.defaultApplicationURLs)
    english = _.find(urls, { language: 'English' })
    chinese = _.find(urls, { language: 'Traditional Chinese' })
    spanish = _.find(urls, { language: 'Spanish' })
    tagalog = _.find(urls, { language: 'Tagalog' })
    # replace download URLs if they are customized on the listing
    listing = Service.listing
    english.url = listing.Download_URL if listing.Download_URL
    chinese.url = listing.Download_URL_Cantonese if listing.Download_URL_Cantonese
    spanish.url = listing.Download_URL_Spanish if listing.Download_URL_Spanish
    tagalog.url = listing.Download_URL_Tagalog if listing.Download_URL_Tagalog
    angular.copy(urls, Service.listingDownloadURLs)

  Service.getProjectIdForBoundaryMatching = (listing) ->
    return unless listing
    if Service.hasPreference('antiDisplacement', listing)
      'ADHP'
    else if Service.hasPreference('neighborhoodResidence', listing)
      listing.Project_ID
    else
      null

  Service.mapSlugToId = (id) ->
    # strip spaces and lowercase the listing names e.g. "Argenta 909" => "argenta909"
    mapping = _.mapKeys _.invert(ListingConstantsService.LISTING_MAP), (v, k) -> k.toLowerCase().replace(/ /g, '')
    slug = id.toLowerCase()
    # by default will just return the id, unless it finds a matching slug
    return if mapping[slug] then mapping[slug] else id

  Service.stubListingPreferences = ->
    opts = null
    if (ListingHelperService.listingIs('Alchemy', Service.listing))
      opts = {
        COPUnits: 50
        DTHPUnits: 10
        NRHPUnits: 20
        NRHPDistrict: 8
      }
    if (ListingHelperService.listingIs('480 Potrero', Service.listing))
      opts = {
        COPUnits: 11
        DTHPUnits: 2
        NRHPUnits: 4
        NRHPDistrict: 10
      }
    if (ListingHelperService.listingIs('21 Clarence', Service.listing))
      opts = {
        COPUnits: 1
        DTHPUnits: 1
        NRHPUnits: 0
      }
    if (ListingHelperService.listingIs('168 Hyde', Service.listing))
      opts = {
        COPUnits: 1
        DTHPUnits: 0
        NRHPUnits: 0
      }
    if (ListingHelperService.listingIs('Olume', Service.listing))
      opts = {
        COPUnits: 18
        DTHPUnits: 3
        NRHPUnits: 7
        NRHPDistrict: 6
      }
    if (ListingHelperService.listingIs('3445 Geary', Service.listing))
      opts = {
        COPUnits: 1
        DTHPUnits: 0
        NRHPUnits: 0
      }
    if (ListingHelperService.listingIs('125 Mason', Service.listing))
      opts = {
        COPUnits: 3
        DTHPUnits: 3
        NRHPUnits: 0
      }
    if (ListingHelperService.listingIs('Argenta 909', Service.listing))
      opts = {
        COPUnits: 1
        DTHPUnits: 1
        NRHPUnits: 0
      }
    if (ListingHelperService.listingIs('Northpoint Vistas', Service.listing))
      opts = {
        COPUnits: 2
        DTHPUnits: 2
        NRHPUnits: 0
      }
    if (ListingHelperService.listingIs('280 Brighton', Service.listing))
      opts = {
        COPUnits: 3
        DTHPUnits: 0
        NRHPUnits: 0
      }
    if (ListingHelperService.listingIs('30 Dore', Service.listing))
      opts = {
        COPUnits: 1
        DTHPUnits: 0
        NRHPUnits: 0
      }
    if opts
      Service.stubPreferences(opts)

  Service.stubPreferences = (options) ->
    defaults = [
      {
        preferenceName: 'Certificate of Preference (COP)'
        description: '''
          Households in which one member holds a Certificate of Preference from the former San Francisco
          Redevelopment Agency. COP holders were displaced by Agency action generally during the 1960s and 1970s.
          '''
        unitsAvailable: options.COPUnits
        readMoreUrl: 'http://sfmohcd.org/certificate-preference'
      },
      {
        preferenceName: 'Displaced Tenant Housing Preference (DTHP)'
        description: '''
          Households in which one member holds a Displaced Tenant Housing Preference Certificate.
          DTHP Certificate holders are people who have been evicted through either an Ellis Act Eviction
          or an Owner Move-In Eviction in 2010 or later. Once all units reserved for this preference are filled,
          remaining DTHP holders will receive Live/Work preference, regardless of their current living or working location.
          '''
        unitsAvailable: options.DTHPUnits
        readMoreUrl: 'http://sfmohcd.org/displaced-tenant-housing-preference-program-0'
      },
      {
        preferenceName: 'Neighborhood Resident Housing Preference (NRHP)'
        description: """
          Households that submit acceptable documentation that at least one member lives either within supervisorial
          District #{options.NRHPDistrict} or within a half-mile of the project.
          """
        unitsAvailable: options.NRHPUnits
        readMoreUrl: 'http://sfmohcd.org/neighborhood-resident-housing-preference'
      },
      {
        preferenceName: 'Live or Work in San Francisco Preference'
        description: '''
          Households that submit acceptable documentation that at least one member lives or works in San Francisco.
          In order to claim Work Preference, you or a household member must currently work in San Francisco at least
          75% of your working hours.
          '''
        unitsAvailable: 'Remaining'
        readMoreUrl: 'http://sfmohcd.org/housing-preference-programs'
      }
    ]

    preferences = []
    i = 1
    defaults.forEach (pref) ->
      if pref.unitsAvailable
        pref.order = i++
        preferences.push(pref)

    Service.listing.preferences = preferences

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

ListingService.$inject = [
  '$http', '$localStorage', '$q', '$state', '$translate', '$timeout',
  'ExternalTranslateService', 'ListingConstantsService', 'ListingHelperService',
  'ListingEligibilityService', 'ListingLotteryService', 'ListingUnitService', 'SharedService'
]

angular
  .module('dahlia.services')
  .service('ListingService', ListingService)

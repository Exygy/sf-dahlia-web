############################################################################################
####################################### SERVICE ############################################
############################################################################################

SharedService = ($http, $state, $window, $document) ->
  Service = {}
  Service.assetPaths = STATIC_ASSET_PATHS
  Service.housingCounselors =
    all: []
    chinese: []
    filipino: []
    spanish: []

  Service.showSharing = () ->
    $state.current.name == "dahlia.favorites"

  # method adapted from:
  # https://www.bignerdranch.com/blog/web-accessibility-skip-navigation-links
  Service.focusOnMainContent = ->
    main = angular.element(document.getElementById('main-content'))
    return unless main
    Service.focusOnElement(main)

  Service.focusOnShortFormContent = ->
    main = document.getElementById('main-content')
    return unless main
    angularElement = angular.element(main)
    Service.focusOnElement(angularElement)
    $document.scrollToElement(angularElement)

  Service.focusOnElement = (el) ->
    return unless el
    # Setting 'tabindex' to -1 takes an element out of normal tab flow
    # but allows it to be focused via javascript
    el.attr 'tabindex', -1
    el.on 'blur focusout', ->
      # when focus leaves this element, remove the tabindex
      angular.element(@).removeAttr('tabindex')
    el[0].focus()

  Service.focusOnBody = ->
    body = angular.element(document.body)
    Service.focusOnElement(body)

  Service.getHousingCounselors = ->
    housingCounselorJsonPath = Service.assetPaths['housing_counselors.json']
    # if we've already loaded this asset, no need to reload
    return if Service.housingCounselors.loaded == housingCounselorJsonPath
    $http.get(housingCounselorJsonPath).success((data, status, headers, config) ->
      Service.housingCounselors.all = data.locations
      Service.housingCounselors.loaded = housingCounselorJsonPath
      Service.housingCounselors.chinese = _.filter data.locations, (o) ->
        _.includes o.languages, 'Cantonese'
      Service.housingCounselors.filipino = _.filter data.locations, (o) ->
        _.includes o.languages, 'Filipino'
      Service.housingCounselors.spanish = _.filter data.locations, (o) ->
        _.includes o.languages, 'Spanish'
    )

  return Service


############################################################################################
######################################## CONFIG ############################################
############################################################################################

SharedService.$inject = ['$http', '$state', '$window', '$document']

angular
  .module('dahlia.services')
  .service('SharedService', SharedService)

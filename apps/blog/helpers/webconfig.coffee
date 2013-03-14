_ = require 'underscore'


webConfig = 
  getHeader : (requestUrl) ->
    urlPrefix = '/blog'
    requestUrl = decodeURI(requestUrl).substring urlPrefix.length
    navData = [
      {
        url : '/'
        title : '首页'
      }
      # {
      #   url : '/node'
      #   title : 'NODE'
      # }
    ]
    
    urlList = _.pluck navData, 'url'
    sortUrlList = _.sortBy urlList, (url) ->
      return -url.length
    baseUrl = ''
    if requestUrl == '/'
      baseUrl = requestUrl
    else
      _.each sortUrlList, (url, i) ->
        if !baseUrl && url != '/'
          if ~requestUrl.indexOf url
            baseUrl = url
    return {
      selectedIndex : _.indexOf urlList, baseUrl
      navData : navData
    }

module.exports = webConfig
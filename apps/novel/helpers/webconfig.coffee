_ = require 'underscore'


webConfig = 
  getHeader : (requestUrl) ->
    urlPrefix = '/xiaoshuo'
    requestUrl = decodeURI(requestUrl).substring urlPrefix.length
    navData = [
      {
        url : '/'
        title : '首页'
      }
      {
        url : '/type/科幻小说'
        title : '科幻小说'
      }
      {
        url : '/type/玄幻魔法'
        title : '玄幻魔法'
      }
      {
        url : '/type/武侠修真'
        title : '武侠修真'
      }
      {
        url : '/type/历史军事'
        title : '历史军事'
      }
      {
        url : '/type/都市言情'
        title : '都市言情'
      }
      {
        url : '/type/侦探推理'
        title : '侦探推理'
      }
      {
        url : '/type/网游动漫'
        title : '网游动漫'
      }
      {
        url : '/type/散文诗词'
        title : '散文诗词'
      }
      {
        url : '/type/恐怖灵异'
        title : '恐怖灵异'
      }
    ]
    
    urlList = _.pluck navData, 'url'
    sortUrlList = _.sortBy urlList, (url) ->
      return -url.length
    baseUrl = ''
    if requestUrl == '/' || requestUrl.indexOf('/page/') == 0
      baseUrl = '/'
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
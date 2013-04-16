appConfig = require '../config'
appPath = appConfig.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"
# sessionParser = require('jtweb').sessionParser()
staticsHost = appConfig.getStaticsHost()

routeInfos = [
  {
    route : ['/', '/tag/:tag']
    jadeView : 'blog/index'
    staticsHost : staticsHost
    handler : pageContentHandler.index
  }
  {
    route : '/article/:id'
    jadeView : 'blog/article'
    staticsHost : staticsHost
    handler : pageContentHandler.article
  }
  {
    route : '/node'
    jadeView : 'blog/node'
    staticsHost : staticsHost
    handler : pageContentHandler.node
  }
  {
    type : 'get'
    route : '/savearticle'
    jadeView : 'blog/savearticle'
    staticsHost : staticsHost
    handler : pageContentHandler.saveArticle
  }
  {
    type : 'post'
    route : '/savearticle'
    handler : pageContentHandler.saveArticle
  }
  {
    type : 'post'
    route : '/mergeajax'
    handler : pageContentHandler.mergeAjax
  }
]
module.exports = routeInfos
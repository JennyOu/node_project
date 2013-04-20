appConfig = require '../config'
appPath = appConfig.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"
sessionParser = require('jtweb').sessionParser()
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
    type : 'all'
    route : '/userinfo'
    middleware : [sessionParser]
    handler : pageContentHandler.userInfo
  }
  {
    route : '/node'
    jadeView : 'blog/node'
    staticsHost : staticsHost
    handler : pageContentHandler.node
  }
  {
    route : ['/savearticle', '/savearticle/:id']
    jadeView : 'blog/savearticle'
    middleware : [sessionParser]
    staticsHost : staticsHost
    handler : pageContentHandler.saveArticle
  }
  {
    type : 'post'
    route : '/statistics'
    handler : pageContentHandler.statistics
  }
  {
    type : 'post'
    route : ['/savearticle', '/savearticle/:id']
    middleware : [sessionParser]
    handler : pageContentHandler.saveArticle
  }
  {
    type : 'post'
    route : '/mergeajax'
    handler : pageContentHandler.mergeAjax
  }
]
module.exports = routeInfos

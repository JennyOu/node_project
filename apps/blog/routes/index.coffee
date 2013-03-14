appConfig = require '../config'
appPath = appConfig.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"

staticsHost = appConfig.getStaticsHost()

routeInfos = [
  {
    route : '/blog'
    jadeView : 'blog/index'
    staticsHost : staticsHost
    handleFunc : pageContentHandler.index
  }
  {
    route : '/blog/article/:id'
    jadeView : 'blog/article'
    staticsHost : staticsHost
    handleFunc : pageContentHandler.article
  }
  {
    route : '/blog/node'
    jadeView : 'blog/node'
    staticsHost : staticsHost
    handleFunc : pageContentHandler.node
  }
  {
    type : 'get'
    route : '/blog/savearticle'
    jadeView : 'blog/savearticle'
    staticsHost : staticsHost
    handleFunc : pageContentHandler.saveArticle
  }
  {
    type : 'post'
    route : '/blog/savearticle'
    handleFunc : pageContentHandler.saveArticle
  }
]

module.exports = (app) ->
  jtWeb = require 'jtweb'
  routeHandler = jtWeb.routeHandler()
  routeHandler.initRoutes app, routeInfos
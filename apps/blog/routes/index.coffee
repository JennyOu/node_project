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
    route : '/ask'
    jadeView : 'blog/ask'
    staticsHost : staticsHost
    middleware : [sessionParser]
    handler : pageContentHandler.ask
  }
  {
    route : '/ask'
    type : 'post'
    middleware : [sessionParser]
    handler : pageContentHandler.ask
  }
  {
    route : '/questions'
    jadeView : 'blog/questions'
    staticsHost : staticsHost
    handler : pageContentHandler.questions
  }
  {
    route : '/question/:id'
    jadeView : 'blog/question'
    staticsHost : staticsHost
    handler : pageContentHandler.question
  }
  {
    route : '/question/:id'
    type : 'post'
    middleware : [sessionParser]
    handler : pageContentHandler.question
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

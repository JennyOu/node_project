appConfig = require '../config'
appPath = appConfig.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"
sessionParser = require('jtweb').sessionParser()
staticsHost = appConfig.getStaticsHost()

routeInfos = [
  {
    route : '/'
    jadeView : 'ys/index'
    staticsHost : staticsHost
    handler : pageContentHandler.index
  }
  {
    route : '/management'
    jadeView : 'ys/management'
    staticsHost : staticsHost
    handler : pageContentHandler.management
  }
  {
    route : ['/sell', '/sell/:id']
    jadeView : 'ys/sell'
    staticsHost : staticsHost
    handler : pageContentHandler.sell
  }
  {
    route : '/buy'
    jadeView : 'ys/buy'
    staticsHost : staticsHost
    handler : pageContentHandler.buy
  }
  {
    route : '/transfer'
    jadeView : 'ys/transfer'
    staticsHost : staticsHost
    handler : pageContentHandler.transfer
  }
  {
    route : '/query'
    jadeView : 'ys/query'
    staticsHost : staticsHost
    handler : pageContentHandler.query
  }
  {
    route : '/items'
    handler : pageContentHandler.items
  }
  {
    route : '/userinfo'
    middleware : [sessionParser]
    handler : pageContentHandler.userInfo
  }
  {
    route : '/adduser'
    type : 'post'
    middleware : [sessionParser]
    handler : pageContentHandler.addUser
  }
  {
    route : '/login'
    type : 'post'
    middleware : [sessionParser]
    handler : pageContentHandler.login
  }
  {
    route : '/logout'
    middleware : [sessionParser]
    handler : pageContentHandler.logout
  }
  {
    route : '/orderno'
    handler : pageContentHandler.orderNo
  }
  {
    route : '/search'
    handler : pageContentHandler.search
  }
  {
    route : '/save'
    middleware : [sessionParser]
    type : 'post'
    handler : pageContentHandler.save
  }
  {
    route : '/tempsave'
    middleware : [sessionParser]
    type : 'post'
    handler : pageContentHandler.tempSave
  }
]
module.exports = routeInfos
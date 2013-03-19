appConfig = require '../config'
appPath = appConfig.getAppPath()
pageContentHandler = require "#{appPath}/helpers/pagecontenthandler"

staticsHost = appConfig.getStaticsHost()

routeInfos = [
  {
    route : '/xiaoshuo'
    jadeView : 'novel/index'
    staticsHost : staticsHost
    handleFunc : pageContentHandler.index
  }
  {
    route : '/xiaoshuo/item/:id'
    jadeView : 'novel/item'
    staticsHost : staticsHost
    handleFunc : pageContentHandler.item
  }
  {
    route : '/xiaoshuo/item/:id/page/:page'
    jadeView : 'novel/itempage'
    staticsHost : staticsHost
    handleFunc : pageContentHandler.itemPage
  }
  {
    route : '/xiaoshuo/getnovel/:id'
    handleFunc : pageContentHandler.getNovel
  }
]

module.exports = routeInfos
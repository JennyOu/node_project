_ = require 'underscore'

SETTING = require './setting.json'

init = ->
  jtWeb = require 'jtweb'
  appName = SETTING.appName
  jtWeb.addInfoParser (req) ->
    if req.host == SETTING.host
      {
        appName : appName
      }
    else
      null
  redisOptions =
    ttl : 60 * 60
  jtWeb.addSessionConfig appName, redisOptions, {
    key : appName
  }

config = 
  getAppPath : () ->
    __dirname
  isProductionMode : () ->
    process.env.NODE_ENV == 'production'
  getStaticsHost : () ->
    if @isProductionMode()
      'http://jennyou.com'
    else
      null
  getMongoDbConfig : () ->
    SETTING.mongoDb
  init : init
  getAppConfig : () ->
    {
      routeInfos : require './routes'
    }
     
module.exports = config
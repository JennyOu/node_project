async = require 'async'
_ = require 'underscore'
require 'date-utils'
config = require './config'
rootPath = config.getRootPath()


getConfigObjs = (cbf) ->
  fs = require 'fs'
  configList = []
  getFiles = (appNames) ->
    _.each appNames, (appName) ->
      if appName.charAt(0) != '.'
        file = "#{rootPath}/apps/#{appName}/config"
        configList.push require file
    cbf null, configList
  launchAppList = config.getLaunchAppList()
  if launchAppList == 'all'
    fs.readdir "#{rootPath}/apps", (err, files) ->
      getFiles files
  else
    launchAppList.unshift 'common'
    getFiles launchAppList
###*
 * getAppConfigList 获取app配置对象列表
 * @param  {[type]} cbf [description]
 * @return {[type]}     [description]
###
getAppConfigList = (cbf) ->
  fs = require 'fs'
  configList = []
  getFiles = (appNames) ->
    _.each appNames, (appName) ->
      if appName.charAt(0) != '.'
        file = "#{rootPath}/apps/#{appName}/config"
        configList.push require(file).getAppConfig()
    cbf null, configList
  launchAppList = config.getLaunchAppList()
  if launchAppList == 'all'
    fs.readdir "#{rootPath}/apps", (err, files) ->
      getFiles files
  else
    launchAppList.unshift 'common'
    getFiles launchAppList

settingMongoDb = (configList, cbf) ->
  jtWeb = require 'jtweb'
  _.each configList, (config) ->
    if _.isFunction config.getMongoDbConfig
      initMongoDb config.getMongoDbConfig()
  cbf null, configList

settingRedis = (configList, cbf) ->
  jtWeb = require 'jtweb'
  _.each configList, (config) ->
    if _.isFunction config.getRedisConfig
      initRedis config.getRedisConfig()
  cbf null, configList

# ###*
#  * startApps 启动apps
#  * @param  {[type]} getAppConfigList [description]
#  * @return {[type]}         [description]
# ###
# startApps = (appConfigList, cbf) ->
#   getAppOptions = (appConfigs) ->
#     defaultOptions = appConfigs.pop()
#     defaultOptions.routeInfos ?= []
#     defaultOptions.middleware ?= []
#     defaultOptions.firstMiddleware ?= []

#     mergeConfig = (key, config) ->
#       if _.isArray config[key]
#         defaultOptions[key] = defaultOptions[key].concat config[key]
#       else if config[key]
#         defaultOptions[key].push config[key]

#     _.each appConfigs, (appConfig) ->
#       mergeConfig 'routeInfos', appConfig
#       mergeConfig 'middleware', appConfig
#       mergeConfig 'firstMiddleware', appConfig

#     defaultOptions
#   defaultPort = config.getListenPort()
#   _.each appConfigList, (appConfig) ->
#     appConfig.port ?= defaultPort
#   groupConfigList = _.groupBy appConfigList, 'port'
#   jtWeb = require 'jtweb'
#   jtRedis = require 'jtredis'

#   appDefaultOptions = 
#     appPath : rootPath
#     redisClient : jtRedis.getClient()
#     viewsPath : config.getViewsPath()
#     staticSetting : [
#       {
#         mountPath : '/statics'
#         path : config.getStaticPath()
#       }
#       {
#         mountPath : '/statics'
#         path : '/Users/Tree/novel_frontcovers'
#       }
#     ]
#     faviconPath : config.getFaviconPath()
#   _.each groupConfigList, (appConfigs) ->
#     appOptions = getAppOptions appConfigs
#     initExpress _.extend {}, appDefaultOptions, appOptions
#   cbf null

initApp = (configList) ->
  jtLogger = require 'jtlogger'
  jtUtil = require 'jtutil'
  jtWeb = require 'jtweb'
  jtRedis = require 'jtredis'
  express = require 'express'

  appConfigs = _.compact _.map configList, (cfg) ->
    if _.isFunction cfg.getAppConfig
      cfg.getAppConfig()
    else
      null


  app = express()

  app.set 'view engine', 'jade'
  app.set 'views', config.getViewsPath()

  jtWeb.set {
    appPaht : rootPath
    redisClient : jtRedis.getClient()
  }

  firstMiddlewares = _.compact _.pluck appConfigs, 'firstMiddleware'
  if firstMiddlewares
    _.each firstMiddlewares, (firstMiddleware) ->
      app.use firstMiddleware

  # 静态文件处理
  app.use '/statics', jtWeb.staticHandler config.getStaticPath()


  # favicon的处理
  app.use express.favicon config.getFaviconPath()

  # express的middleware处理，在静态文件和favicon之后
  middlewares = _.compact _.pluck appConfigs, 'middleware'
  if middlewares
    _.each middlewares, (middleware) ->
      app.use middleware

  if config.isProductionMode()
    app.use express.limit '1mb'
    app.use jtLogger.getConnectLogger 'HTTP-INFO-LOGGER', {
      format : express.logger.tiny
    }
  else
    app.use express.logger 'dev'

  app.use express.bodyParser()
  app.use express.methodOverride()

  # 每个应用的信息处理
  app.use jtWeb.infoParser()

  # 用于输出非缓存的信息处理（主要是个人信息）
  app.use jtWeb.nocacheInfoParser()

  app.use app.router

  routeInfosList = _.compact _.pluck appConfigs, 'routeInfos'
  if routeInfosList
    routeHandler = jtWeb.routeHandler()
    _.each routeInfosList, (routeInfos) ->
      routeHandler.initRoutes app, routeInfos

  # 错误页面处理输出
  app.use jtWeb.errorPageHandler()

  app.listen config.getListenPort()
  _.each configList, (cfg) ->
    if _.isFunction cfg.init
      cfg.init()
  console.info "listen port #{config.getListenPort()}" 


async.waterfall [
  getConfigObjs
  settingMongoDb
  settingRedis
  initApp
]


initMongoDb = (dbConfigs) ->
  jtMongoDb = require 'jtmongodb'
  jtRedis = require 'jtredis'
  defaultConfig = 
    immediatelyInit : true
    options :
      w : 0
      native_parser : false
      auto_reconnect : true
      read_secondary : true
      readPreference : 'secondaryPreferred'
  if !_.isArray dbConfigs
    dbConfigs = [dbConfigs]
  _.each dbConfigs, (dbConfig, i) ->
    dbConfigs[i] = _.extend defaultConfig, dbConfig
  delete dbConfigs.cacheClient
  jtMongoDb.set {
    queryTime : true
    valiate : true
    timeOut : 0
    ttl : 0
    cacheClient : jtRedis.getClient()
    mongodb : dbConfigs
    logger : require('jtlogger').getLogger 'MONGODB'
  }

initRedis = (config) ->
  config = _.clone config
  jtRedis = require 'jtredis'
  jtRedis.setConfig {
    queryTime : true
    redis : config
  }


# async.waterfall [
#   getAppConfigList
#   settingMongoDb
#   settingRedis
#   startApps
# ], (err) ->
#   console.dir 'start node successful!'
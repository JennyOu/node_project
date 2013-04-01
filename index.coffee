async = require 'async'
_ = require 'underscore'
config = require './config'
rootPath = config.getRootPath()

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
  if config.getLaunchAppList() == 'all'
    fs.readdir "#{rootPath}/apps", (err, files) ->
      getFiles files
  else
    getFiles launchAppList


settingMongoDb = (configList, cbf) ->
  jtWeb = require 'jtweb'
  _.each configList, (config) ->
    if config.mongoDbConfig
      jtWeb.initMongoDb config.mongoDbConfig
  cbf null, configList

settingRedis = (configList, cbf) ->
  jtWeb = require 'jtweb'
  _.each configList, (config) ->
    if config.redisConfig
      jtWeb.initRedis config.redisConfig
  cbf null, _.pluck configList, 'app'

###*
 * startApps 启动apps
 * @param  {[type]} getAppConfigList [description]
 * @return {[type]}         [description]
###
startApps = (appConfigList, cbf) ->
  getAppOptions = (appConfigs) ->
    defaultOptions = appConfigs.pop()
    defaultOptions.routeInfos ?= []
    defaultOptions.middleware ?= []
    _.each appConfigs, (appConfig) ->
      defaultOptions.routeInfos =  defaultOptions.routeInfos.concat appConfig.routeInfos
      defaultOptions.middleware = defaultOptions.middleware.concat appConfig.middleware
    return defaultOptions
  defaultPort = config.getListenPort()
  _.each appConfigList, (appConfig) ->
    appConfig.port ?= defaultPort
  groupConfigList = _.groupBy appConfigList, 'port'
  jtWeb = require 'jtweb'
  jtRedis = require 'jtredis'

  appDefaultOptions = 
    appPath : rootPath
    redisClient : jtRedis.getClient()
    viewsPath : config.getViewsPath()
    staticSetting : [
      {
        mountPath : '/statics'
        path : config.getStaticPath()
      }
      {
        mountPath : '/statics'
        path : '/Users/Tree/novel_frontcovers'
      }
    ]
    faviconPath : config.getFaviconPath()
  _.each groupConfigList, (appConfigs) ->
    appOptions = getAppOptions appConfigs
    jtWeb.initApp _.extend {}, appDefaultOptions, appOptions
  cbf null

async.waterfall [
  getAppConfigList
  settingMongoDb
  settingRedis
  startApps
], (err) ->
  console.dir 'start node successful!'
  


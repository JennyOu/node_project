_ = require 'underscore'

initApp = (options) ->
  jtLogger = require 'jtlogger'
  jtWeb = require 'jtweb'
  jtUtil = require 'jtutil'
  express = require 'express'

  defaults = 
    viewEngine : 'jade'
  opts = _.extend defaults, options

  app = express()

  app.set 'view engine', opts.viewEngine
  app.set 'views', opts.viewsPath

  jtWeb.set {
    appPath : opts.rootPath
    redisClient : opts.redisClient
  }

  if opts.firstMiddleware
    app.use opts.firstMiddleware


  # 静态文件处理
  if !_.isArray opts.staticSetting
    opts.staticSetting = [opts.staticSetting]
  _.each opts.staticSetting, (staticSetting) ->
    if staticSetting.mountPath
      app.use staticSetting.mountPath, jtWeb.staticHandler staticSetting.path
    else
      app.use jtWeb.staticHandler staticSetting.path

  # favicon的处理
  if opts.faviconPath
    app.use express.favicon opts.faviconPath

  # express的middleware处理，在静态文件和favicon之后
  if opts.middleware
    if !_.isArray opts.middleware
      opts.middleware = [opts.middleware]
    _.each opts.middleware, (middleware) ->
      app.use middleware

  if opts.mode == 'production'
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

  # 错误页面处理输出
  app.use jtWeb.errorPageHandler()

  if opts.routeFiles
    if !_.isArray opts.routeFiles
      opts.routeFiles = [opts.routeFiles]
    _.each opts.routeFiles, (routeFile) ->
      jtUtil.requireFileExists routeFile, (exists) ->
        if exists
          require(routeFile) app

  app.listen opts.port
  logger = jtLogger.getLogger __filename
  logger.info "listen port #{opts.port}"

initMongoDb = (dbConfigs) ->
  jtMongoDb = require 'jtmongodb'
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
  jtMongoDb.set {
    queryTime : true
    valiate : true
    timeOut : 0
    mongodb : dbConfigs
  }

initRedis = (config) ->
  config = _.clone config
  jtRedis = require 'jtredis'
  jtRedis.setConfig {
    queryTime : true
    redis : config
  }

module.exports = 
  initApp : initApp
  initRedis : initRedis
  initMongoDb : initMongoDb
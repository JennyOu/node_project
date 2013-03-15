async = require 'async'
_ = require 'underscore'
config = require './config'
rootPath = config.getRootPath()

###*
 * getRouteFiles 获取路由文件
 * @param  {[type]} cbf [description]
 * @return {[type]}     [description]
###
getRouteFiles = (cbf) ->
  fs = require 'fs'
  resultFiles = []
  getFiles = (appNames) ->
    _.each appNames, (appName) ->
      if appName.charAt(0) != '.'
        file = "#{rootPath}/apps/#{appName}/init"
        resultFiles.push file
        cbf null, resultFiles
  if config.getLaunchAppList() == 'all'
    fs.readdir "#{rootPath}/apps", (err, files) ->
      getFiles files
  else
    getFiles launchAppList

initLogger = () ->
  jtLogger = require 'jtlogger'

getMongoDbConfig = (cbf) ->
  cbf null, {
    dbName : 'vicanso'
    uri : 'mongodb://localhost:10020/vicanso'
  }

getRedisConfig = (cbf) ->
  cbf null, {
    name : 'vicanso'
    uri : 'redis://localhost:10010'
    pwd : 'MY_REDIS_PWD'
  }

###*
 * startApps 启动apps
 * @param  {[type]} err     [description]
 * @param  {[type]} results [description]
 * @return {[type]}         [description]
###
startApps = (err, results) ->
  if err
    return
  jtWeb = require 'jtweb'
  jtRedis = require 'jtredis'
  jtWeb.initMongoDb results.mongoDbConfig

  jtWeb.initRedis results.redisConfig


  appOptions = 
    rootPath : rootPath
    firstMiddleware : (req, res, next) ->
      console.dir req.url
      next()
    redisClient : null
    routeFiles : results.routeFiles
    viewsPath : config.getViewsPath()
    staticSetting : 
      mountPath : '/statics'
      path : config.getStaticPath()
    faviconPath : config.getFaviconPath()
    port : config.getListenPort()
    middleware : (req, res, next) ->
      if req.url == '/healthchecks'
        res.send 'success'
        return 
      else if req.host == 'blog.vicanso.com'
        req.url = '/blog' + req.url
        req.originalUrl = req.url
      else if req.host == 'ys.vicanso.com'
        req.url = '/ys' + req.url
        req.originalUrl = req.url
      next()
  jtWeb.initApp appOptions

async.parallel {
  routeFiles : getRouteFiles
  mongoDbConfig : getMongoDbConfig
  redisConfig : getRedisConfig
}, startApps
  


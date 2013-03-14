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
  

###*
 * startApps 启动apps
 * @param  {[type]} err     [description]
 * @param  {[type]} results [description]
 * @return {[type]}         [description]
###
startApps = (err, results) ->
  if err
    return
  appOptions = 
    rootPath : rootPath
    redisClient : null
    firstMiddle : null
    routeFiles : results.routeFiles
    staticSetting : 
      mountPath : '/static'
      path : config.getStaticPath()
    faviconPath : config.getFaviconPath()
    port : config.getListenPort()
    middleware : (req, res, next) ->
      if req.url == '/healthchecks'
        res.send 'success'
      else if req.host == 'blog.vicanso.com'
        req.url = '/blog' + req.url
        req.originalUrl = req.url
      else if req.host == 'ys.vicanso.com'
        req.url = '/ys' + req.url
        req.originalUrl = req.url
      next()
  app = require './app'
  app.initApp appOptions

async.parallel {
  routeFiles : getRouteFiles
}, startApps
  


path = require 'path'
commander = require 'commander'
_ = require 'underscore'


do (commander) ->
  splitArgs = (val) ->
    return val.split ','
  commander.version('0.0.1')
  .option('-p, --port <n>', 'listen port', parseInt)
  .option('-s, --slaver <n>', 'slaver total', parseInt)
  .option('-l, --launchapps <items>', 'the luanch app list, separated by ","', splitArgs)
  .option('--log <n>', 'the log file\'s path(in production mode)')
  .option('--err <n>', 'the error log file\'s path(in production mode)')
  .parse process.argv


config = 
  ###*
   * getRootPath 返回整个node项目的所在的目录
   * @return {String} [description]
  ###
  getRootPath : () ->
    return __dirname
  ###*
   * isProductionMode 判断当前APP是否运行在production环境下
   * @return {Boolean} [description]
  ###
  isProductionMode : () ->
    return process.env.NODE_ENV is 'production'
  ###*
   * getListenPort 返回APP的监听端口
   * @return {Number} [description]
  ###
  getListenPort : () ->
    return commander.port || 10000
  ###*
   * isMaster 是否master，在程序运行之后才去设置，因此不要在require config之后就直接调用
   * @return {Boolean} [description]
  ###
  isMaster : () ->
    cluster = require 'cluster'
    return cluster.isMaster || false
  ###*
   * getViewsPath 返回view的目录
   * @return {String} [description]
  ###
  getViewsPath : () ->
    return path.join @getRootPath(), '/views'
  ###*
   * getStaticPrefix 返回静态文件请求的HTTP请缀
   * @return {String} [description]
  ###
  getStaticPrefix : () ->
    return '/statics'
  ###*
   * [getStaticPath 返回静态文件路径]
   * @return {[type]} [description]
  ###
  getStaticPath : () ->
    return path.join @getRootPath(), @getStaticPrefix()
  ###*
   * getFaviconPath 返回favicon图标的路径
   * @return {[type]}
  ###
  getFaviconPath : () ->
    return path.join @getStaticPath(), '/common/images/favicon.png'
  ###*
   * getLogPath 返回输出该log的文件相对路径
   * @param  {String} fileName 该文件路径
   * @return {[type]}          [description]
  ###
  getLogRelativePath : (fileName) ->
    return fileName.replace @getRootPath(), ''
  ###*
   * getSlaveTotal 返回从进程的总数
   * @return {Number} [description]
  ###
  getSlaverTotal : () ->
    return commander.slaver || (require('os').cpus().length - 1) || 1
  ###*
   * getLaunchAppList 获取启动app的列表
   * @return {Array, String} [description]
  ###
  getLaunchAppList : () ->
    return commander.launchapps || 'all'
  ###*
   * getUID 获取node的uid(如果是master则返回0)
   * @return {Number} [description]
  ###
  getUID : () ->
    cluster = require 'cluster'
    if @isMaster()
      return 0
    else
      return cluster.worker.uniqueID || -1

module.exports = config
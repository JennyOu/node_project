_ = require 'underscore'
SETTING = require './setting.json'
weibo = require 'weibo'
weibo.init 'weibo', SETTING.weibo.appKey, SETTING.weibo.appSecret

init = () ->
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
    # ttl的单位为S
    ttl : 30 * 60
  jtWeb.addSessionConfig appName, redisOptions, {
    key : appName
  }

# init = (app) ->
#   jtWeb = require 'jtweb'
#   appName = appConfig.appName
#   prefixUrl = appConfig.prefixUrl
#   require('./routes') app

#   jtWeb.addInfoParser (req) ->
#     if req.url.indexOf(prefixUrl) == 0
#       return {
#         appName : appName
#       }
#     else
#       return null
#   redisOptions = 
#     # ttl的单位为S
#     ttl : 30 * 60
#   jtWeb.addSessionConfig appName, redisOptions, {
#     key : appName
#   }

# module.exports = init


# /**
#  * Create a web application.
#  */

# var app = connect(
#   connect.query(),
#   connect.cookieParser('oh year a cookie secret'),
#   connect.session({ secret: "oh year a secret" }),
#   // using weibo.oauth middleware for use login
#   // will auto save user in req.session.oauthUser
#   weibo.oauth({
#     loginPath: '/login',
#     logoutPath: '/logout',
#     blogtypeField: 'type',
#     afterLogin: function (req, res, callback) {
#       console.log(req.session.oauthUser.screen_name, 'login success');
#       process.nextTick(callback);
#     },
#     beforeLogout: function (req, res, callback) {
#       console.log(req.session.oauthUser.screen_name, 'loging out');
#       process.nextTick(callback);
#     }
#   }),
#   connect.errorHandler({ stack: true, dump: true })
# );

wrapperRouteHandler = (routeInfos) ->
  wrapper = (func, req, res, cbf, next) ->
    if req.host == host || req.host == 'vicanso.com'
        func req, res, cbf, next
      else
        next
  host = SETTING.host
  _.each routeInfos, (routeInfo) ->
    routeInfo.handler = _.wrap routeInfo.handler, wrapper
  routeInfos

oauth = weibo.oauth {
  loginPath : '/login'
  logoutPath : '/logout'
  blogtypeField : 'type'
  afterLogin : (req, res, cbf) ->
    console.dir req.session
}

blogMiddleware = (req, res, next) ->
  req.session = {}
  if req.url == '/healthchecks'
    res.send 'success'
  else
    next()

config = 
  getAppPath : () ->
    __dirname
  authorization : () ->
    admin = SETTING.admin
    (req, res, next) ->
      if req.query?.name == admin
        req.level = 9
      next()
  isProductionMode : () ->
    process.env.NODE_ENV == 'production'
  getStaticsHost : () ->
    if @isProductionMode()
      'http://s.vicanso.com'
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
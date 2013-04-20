
novelMiddleware = (req, res, next) ->
  if req.url == '/healthchecks'
    res.send 'success'
    return
  else if req.host == 'xiaoshuo.vicanso.com'
    req.url = '/xiaoshuo' + req.url
    req.originalUrl = req.url
  next()

config = 
  getAppPath : () ->
    return __dirname
  isProductionMode : () ->
    return process.env.NODE_ENV is 'production'
  getStaticsHost : () ->
    if @isProductionMode()
      return 'http://s.vicanso.com'
    else
      return null
  getMongoDbConfig : () ->
    {
      dbName : 'novel'
      uri : 'mongodb://localhost:10020/novel'
    }
  getAppConfig : () ->
    {
      routeInfos : require './routes'
      middleware : [novelMiddleware]
    }
     
# do () ->
#   novelDbClient = require('jtmongodb').getClient 'novel'
#   setTimeout () ->
#     novelDbClient.ensureIndex 'items', 'author', () ->
#     novelDbClient.ensureIndex 'items', 'bookId', () ->
#     novelDbClient.ensureIndex 'items', 'name', () ->
#     novelDbClient.ensureIndex 'items', {author : 1, name : 1}, () ->

#     novelDbClient.ensureIndex 'us23', {author : 1, name : 1}, () ->
#   , 500

module.exports = config
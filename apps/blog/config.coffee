
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
  getAppConfig : () ->
    return {
      mongoDbConfig : 
        dbName : 'vicanso'
        uri : 'mongodb://localhost:10020/vicanso'
      redisConfig : 
        name : 'vicanso'
        uri : 'redis://localhost:10010'
        pwd : 'MY_REDIS_PWD'
      app : 
        routeInfos : require './routes'
        middleware : (req, res, next) ->
          if req.url == '/healthchecks'
            res.send 'success'
            return
          else if req.host == 'blog.vicanso.com'
            req.url = '/blog' + req.url
            req.originalUrl = req.url
          next()
    }
     

module.exports = config
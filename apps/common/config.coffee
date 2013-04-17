SETTING = require './setting.json'
healthChecks = (req, res, next) ->
  if req.url == '/healthchecks'
    res.send 'success'
  else
    next()

config = 
  getAppConfig : () ->
    {
      redisConfig : 
        name : 'vicanso'
        uri : 'redis://localhost:10010'
        pwd : SETTING.redis.pwd
      app : 
        firstMiddleware : healthChecks
    }
     
module.exports = config
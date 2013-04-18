SETTING = require './setting.json'
healthChecks = (req, res, next) ->
  if req.url == '/healthchecks'
    res.send 'success'
  else
    next()

config = 
  getAppConfig : () ->
    {
      redisConfig : SETTING.redis
      app : 
        firstMiddleware : healthChecks
    }
     
module.exports = config
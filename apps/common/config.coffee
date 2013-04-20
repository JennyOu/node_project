SETTING = require './setting.json'
healthChecks = (req, res, next) ->
  if req.url == '/healthchecks'
    res.send 'success'
  else
    next()

config = 
  getRedisConfig : () ->
    SETTING.redis
  getAppConfig : () ->
    {
      firstMiddleware : healthChecks
    }
     
module.exports = config
rootConfig = require '../../config'

config = 
  getAppPath : () ->
    return __dirname
  getStaticsHost : () ->
    if rootConfig.isProductionMode()
      return 'http://s.vicanso.com'
    else
      return null

module.exports = config
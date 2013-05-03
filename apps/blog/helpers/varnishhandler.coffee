request = require 'request'

varnishHandler = 
  refresh : (url) ->
    request {
      url : url
      method : 'PURGE'
    }, (err, res, body) ->
      console.dir body
module.exports = varnishHandler
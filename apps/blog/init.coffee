

init = (app) ->
  require('./routes') app

  jtWeb = require 'jtweb'
module.exports = init
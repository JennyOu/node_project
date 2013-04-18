vicansoDbClient = require('jtmongodb').getClient 'vicanso'

records = []
recordTimer = null

statistics = 
  record : (data) ->
  	records.push data
  	vicansoDbClient.find 'statistics', {}, (err, docs) ->
  		console.dir docs
  	if !recordTimer
  		recordTimer = GLOBAL.setTimeout () ->
  			recordsBak = records
  			vicansoDbClient.save 'statistics', recordsBak, (err) ->
  				if err
  					console.dir err
  					records = records.concat recordsBak
  			records = []
  			recordTimer = null
  		, 10 * 1000
module.exports = statistics
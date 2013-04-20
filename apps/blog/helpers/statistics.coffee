blogDbClient = require('jtmongodb').getClient 'blog'

records = []
recordTimer = null

statistics = 
  record : (data) ->
    data.createdAt = new Date()
    records.push data
    if !recordTimer
      recordTimer = GLOBAL.setTimeout () ->
        recordsBak = records
        blogDbClient.save 'statistics', recordsBak, (err) ->
          if err
            console.dir err
            records = records.concat recordsBak
        records = []
        recordTimer = null
      , 10 * 1000
module.exports = statistics
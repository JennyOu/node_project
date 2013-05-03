blogDbClient = require('jtmongodb').getClient 'blog'
_ = require 'underscore'
async = require 'async'
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
  set : (type, ids) ->
    if !_.isArray ids
      ids = [ids]
    _.delay () ->
      async.eachLimit ids, 5, (id, cbf) ->
        query = 
          type : type
          id : id.toString()
        async.waterfall [
          (cbf) ->
            blogDbClient.count 'statistics', query, cbf
          (count, cbf) ->
            updateData = {}
            updateData[type] = count
            blogDbClient.findByIdAndUpdate 'articles', id, updateData, cbf
        ], (err) ->
          cbf null
    , 50

module.exports = statistics
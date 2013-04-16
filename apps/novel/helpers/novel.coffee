novelDbClient = require('jtmongodb').getClient 'novel'
async = require 'async'
_ = require 'underscore'
fs = require 'fs'
path = require 'path'
{Qidian, US23} = require 'jtnovel'
levenshtein = require './levenshtein'
novel = 
  sync : (cbf) ->
    async.waterfall [
      (cbf) ->
        novelDbClient.find 'items', {}, {limit : 0}, 'author name sourceInfo', cbf
      (docs, cbf) ->
        async.eachLimit docs, 5, (doc, cbf) ->
          query = _.pick doc, ['author', 'name']
          novelDbClient.find 'us23', query, (err, results) ->
            if results.length
              us23 = _.pick results[0], ['baseUrl', 'bookId']
              sourceInfo = doc.sourceInfo
              sourceInfo.us23 = us23
              updateData = 
                sourceInfo : sourceInfo
              novelDbClient.findByIdAndUpdate 'items', doc._id, updateData, cbf
            else
              cbf err
        , cbf
    ], (err) ->
      cbf err
  update : (bookId, cbf) ->
    novelDbClient.findOne 'items', {bookId : bookId}, (err, doc) ->
      if err
        cbf err
        return
      chapterInfos = doc.chapterInfos
      us23Info = doc.sourceInfo.us23
      us23 = new US23 us23Info.bookId, '/Users/Tree/tmp', us23Info
      baseUrl = us23Info.baseUrl
      savePath = "/Users/Tree/novel/#{doc.author}/#{doc.name}/"
      async.waterfall [
        (cbf) ->
          us23.getPageInfoList cbf
        (pageInfos, cbf) ->
          index = -1
          newChapterInfos = []
          _.each chapterInfos, (chapterInfo, i) ->
            if chapterInfo.download
              newChapterInfos.push chapterInfo
            else if index == -1
              index = i
          targetIndex = -1
          if !chapterInfos[index]
            cbf null, null
            return 
          title = chapterInfos[index].title
          targetIndex = getMostSimilarIndex title, pageInfos
          pageInfos = pageInfos.slice targetIndex

          downloadOtherFiles us23, baseUrl, pageInfos, savePath, (err, result) ->
            newChapterInfos = newChapterInfos.concat result
            cbf err, newChapterInfos
      ], (err, result) ->
        if err || !result
          cbf err
        else
          novelDbClient.findByIdAndUpdate 'items', doc._id, {chapterInfos : result}, cbf
  updateAll : (query, cbf) ->
    novelDbClient.find 'items', query, {limit : 0, skip : 0}, (err, docs) ->
      errList = []
      async.eachLimit docs, 10, (doc, cbf) ->
        novel.update doc.bookId, (err) ->
          if err
            errList.push "fail, id:#{doc.bookId}"
            errList.push err
            errList.push '\n'
          else
            cbf null
      , (err) ->
        if err
          cbf err
        else if errList.length
          cbf new Error JSON.strigify errList
        else
          cbf null


# setTimeout () ->
#   query = 
#     'sourceInfo.us23' : 
#         '$exists' : true
#   novelClient.find 'items', query, (err, docs) ->
#     errList = []
#     async.eachLimit docs, 1, (doc, cbf) ->
#       novel.update doc.bookId, (err) ->
#         if err
#           errList.push 'fail, id:#{doc.bookId}'
#           errList.push err
#           errList.push '\n'
#         else
#           console.dir "complete:#{doc.bookId}"
#         cbf null
#     , (err) ->
#       console.dir 'complete all'
#       console.dir errList
# , 500

downloadOtherFiles = (us23, baseUrl, pageInfos, savePath, cbf) ->
  newChapterInfos = []
  async.eachLimit pageInfos, 1, (pageInfo, cbf) ->
    getContent us23, pageInfo, (err, data) ->
      if err
        cbf err
      else
        newChapterInfos.push {
          title : pageInfo.title
          download : true
          url : baseUrl + pageInfo.url
        }
        fs.writeFile "#{savePath}#{pageInfo.title}.txt", data, (err) ->
          cbf null
  , (err) ->
    cbf err, newChapterInfos
getMostSimilarIndex = (title, pageInfos) ->
  max = 9999
  index = -1
  _.each pageInfos, (pageInfo, i) ->
    sim = levenshtein title, pageInfo.title
    if sim < max
      index = i
      max = sim
  index

getContent = (us23, pageInfo, cbf) ->
  async.waterfall [
    (cbf) ->
      us23.getOnePage pageInfo, cbf
    (content) ->
      cbf null, us23.getContent content
  ], cbf

module.exports = novel
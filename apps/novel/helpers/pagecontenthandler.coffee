_ = require 'underscore'

appConfig = require '../config'
appPath = appConfig.getAppPath()
webConfig = require "#{appPath}/helpers/webconfig"
async = require 'async'
fs = require 'fs'
Novel23US = require './novel23us'
async = require 'async'
novelDbClient = require('jtmongodb').getClient 'novel'


pageContentHandler = 
  index : (req, res, cbf) ->
    viewData =
      header : webConfig.getHeader req.url
    eachPageItemTotal = 28
    page = GLOBAL.parseInt req.params.page || 1
    query = 
      publish : true
    options = 
      limit : eachPageItemTotal
    query.type = req.params.type if req.params.type?
    async.parallel {
      count : (cbf) ->
        novelDbClient.count 'items', query, cbf
      docs : (cbf) ->
        novelDbClient.find 'items', query, options, 'author type name desc', (err, docs) ->
          cbf err, docs
    }, (err, results) ->
      count = results.count
      docs = results.docs
      results = [[], [], [], []]
      strSizeList = []
      divideTotal = results.length
      _.each _.sortBy(docs, (doc) ->
        doc.desc.length
      ), (doc, i) ->
        results[i % divideTotal].push doc
      results = _.map results, (result) ->
        _.shuffle result
      viewData.novelsList = results

      if query.type
        urlPrefix = "/type/#{query.type}"
      else
        urlPrefix = ''
      end = Math.ceil count / eachPageItemTotal
      console.dir page

      start = Math.max 1, page - 2
      if end > 5
        start = Math.min end - 5, start
      viewData.pageInfo = 
        urlPrefix : urlPrefix
        start : start
        current : page
        end : end

      cbf null, {
        title : '简约小说网'
        viewData : viewData
      }
  item : (req, res, cbf) ->
    viewData = 
      header : webConfig.getHeader req.url
    id = req.params.id
    if !id
      cbf new Error 'the param id is null'
      return
    novelDbClient.findById 'items', id, (err, doc) ->
      if err
        cbf err
        return
      viewData.novel = doc
      viewData.baseUrl = "/item/#{id}"
      cbf null, {
        title : "#{doc.name}（简约小说网）"
        viewData : viewData
      }
  itemPage : (req, res, cbf) ->
    viewData = 
      header : webConfig.getHeader req.url
    id = req.params.id
    page = GLOBAL.parseInt(req.params.page) - 1
    if !id? || !page?
      cbf new Error 'the param id or page is null'
      return
    async.waterfall [
      (cbf) ->
        novelDbClient.findById 'items', id, (err, doc) ->
          if err
            cbf err
            return
          name = doc.name
          title = doc.pages[page].title
          if page > 0
            viewData.prevPageUrl = "/item/#{id}/page/#{page}"
          viewData.baseUrl = "/item/#{id}"
          if page < doc.pages.length - 1
            viewData.nextPageUrl = "/item/#{id}/page/#{page + 2}"
          fileName = title + '.txt'
          viewData.title = title
          path = require 'path'
          cbf null, "#{name} #{title}（简约小说网）", path.join '/Users/Tree/novel', doc.author, name, fileName
      (title, file, cbf) ->
        fs.readFile file, 'utf8', (err, data) ->
          console.dir data
          if err
            cbf err
          else
            cbf null, title, data
    ], (err, title, data) ->
      viewData.contentList = data.split '\r\n'
      cbf null, {
        title : title
        viewData : viewData
      }
  getNovel : (req, res, cbf) ->
    id = req.params.id
    new Novel23US(id, '/Users/Tree/novel').start (err, data) ->
      if err
        console.dir err
      else
        novelDbClient.save 'items', data
        console.dir 'success'
    cbf null, {
      code : 0
      msg : id
    }

# finished = false
# skip = 0
# categories = []
# setTimeout () ->
#   async.whilst () ->
#     !finished
#   , (cbf) ->
#     novelDbClient.find 'items', {publish : true}, {skip : skip}, (err, docs) ->
#       console.dir "skip:#{skip}"
#       if err
#         cbf err
#       else if !docs?.length
#         finished = true
#         cbf null
#       else
#         skip += docs.length
#         async.eachLimit docs, 5, (doc, cbf) ->
#           if !~_.indexOf categories, doc.type
#             categories.push doc.type
#           process.nextTick () ->
#             cbf null
#         , (err) ->
#           cbf err
#   , (err) ->
#     console.dir categories
#     console.dir 'complete'
#     if err
#       console.error err
# , 1000

# test = (id, cbf) ->
#   new Novel23US(id, '/Users/Tree/novel').start (err, data) ->
#     if err
#       console.dir id
#       console.dir err
#     else if data
#       novelDbClient.findAndRemove 'items', {bookId : data.bookId}, (err) ->
#         novelDbClient.save 'items', data, () ->
#           console.dir "#{id} success"
#     cbf null
# arr = _.range 26480, 30000
# async.eachLimit arr, 2, (item, cbf) ->
#   test item, cbf
# , (err) ->
#   setTimeout () ->
#     console.dir 'all complete'
#   , 1000


module.exports = pageContentHandler
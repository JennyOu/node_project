_ = require 'underscore'

appConfig = require '../config'
appPath = appConfig.getAppPath()
webConfig = require "#{appPath}/helpers/webconfig"
async = require 'async'
fs = require 'fs'
Novel23US = require './novel23us'

novelDbClient = require('jtmongodb').getClient 'novel'


pageContentHandler = 
  index : (req, res, cbf) ->
    viewData =
      header : webConfig.getHeader req.url
    novelDbClient.find 'items', {}, 'author type name', (err, docs) ->
      if err
        cbf err
        return
      results = [[], [], [], []]
      divideTotal = results.length
      _.each docs, (doc, i) ->
        results[i % divideTotal].push doc
      viewData.novelsList = results
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
      console.dir viewData.baseUrl
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
          cbf null, "#{name} #{title}（简约小说网）", path.join '/Users/Tree/tmp', name, fileName
      (title, file, cbf) ->
        fs.readFile file, 'utf8', (err, data) ->
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

test = (id, cbf) ->
  new Novel23US(id, '/Users/Tree/novel').start (err, data) ->
    if err
      console.dir id
      console.dir err
    else
      novelDbClient.save 'items', data, () ->
        console.dir "#{id} success"
    cbf null
arr = _.range 74, 200
async.eachLimit arr, 2, (item, cbf) ->
  test item, cbf
, (err) ->
  setTimeout () ->
    console.dir 'all complete'
  , 1000


module.exports = pageContentHandler
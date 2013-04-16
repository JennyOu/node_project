_ = require 'underscore'

appConfig = require '../config'
appPath = appConfig.getAppPath()
webConfig = require "#{appPath}/helpers/webconfig"
async = require 'async'
fs = require 'fs'
jtfs = require 'jtfs'
async = require 'async'
# OssClient = require 'jtaliyunoss'
novelDbClient = require('jtmongodb').getClient 'novel'
novel = require './novel'
{Qidian, US23} = require 'jtnovel'


pageContentHandler = 
  index : (req, res, cbf) ->
    viewData =
      header : webConfig.getHeader req.url
    eachPageItemTotal = 28
    page = GLOBAL.parseInt req.params.page || 1
    query = {}
    options = 
      limit : eachPageItemTotal
    query.type = req.params.type if req.params.type?
    async.parallel {
      count : (cbf) ->
        novelDbClient.count 'items', query, cbf
      docs : (cbf) ->
        novelDbClient.find 'items', query, options, 'author type name desc bookId', (err, docs) ->
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

  ossSync : (req, res, cbf) ->
    novelPath = '/Users/Tree/novel'
    ossClient = new OssClient 'akuluq6no78cynryy8nfbl23', 'k6k0jKekWlZn0ciqKLZr+mwrozo='
    syncPath = (filePath, cbf) ->
      completeTotal = 0
      failFiles = []
      async.waterfall [
        (cbf) ->
          jtfs.getFiles filePath, cbf
        (infos, cbf) ->
          jtfs.getFiles infos.dirs, cbf
        (infos, cbf) ->
          async.eachLimit infos.files, 10, (file, cbf) ->
            if !(completeTotal % 10)
              console.dir completeTotal
            completeTotal++
            ossPath = file.substring novelPath.length + 1
            ossClient.updateObject 'vicansonovel', ossPath, file, (err) ->
              if err
                failFiles.push file
              cbf null
          , cbf
      ], (err) ->
        cbf err, failFiles
        console.dir 'complete'
    async.waterfall [
      (cbf) ->
        jtfs.getFiles novelPath, cbf
      (infos, cbf) ->
        failFiles = []
        async.eachLimit infos.dirs, 1, (dir, cbf) ->
          syncPath dir, (err, files) ->
            failFiles = failFiles.concat files
        , cbf
    ], (err) ->
      if err
        console.dir err
      console.dir failFiles
      console.dir 'all complete'

  sync : (req, res, cbf) ->
    novel.sync (err) ->
      if err
        cbf err
      else
        cbf null, {
          code : 0
          msg : 'sync novel success!'
        }
  update : (req, res, cbf) ->


  updateAll : (req, res, cbf) ->
    query = 
      'sourceInfo.us23' : 
        '$exists' : true
    novel.updateAll query, (err) ->
      if err
        cbf err
      else
        cbf null, {
          code : 0
          msg : 'update all success!'  
        }


module.exports = pageContentHandler
_ = require 'underscore'

appConfig = require '../config'
appPath = appConfig.getAppPath()
webConfig = require "#{appPath}/helpers/webconfig"
markdown = require('markdown').markdown
async = require 'async'
hljs = require 'highlight.js'
fs = require 'fs'
blogDbClient = require('jtmongodb').getClient 'blog'
statistics = require './statistics'

highLight = (str) ->
  appendLineNo = (code) ->
    codeList = code.split '\n'
    _.map(codeList, (code, i) ->
      "<span class='lineNo'>#{i + 1}</span>#{code}"
    ).join '\n'


  str = str.replace(/&#39;/g, "'").replace(/&quot;/g, '"').replace(/&amp;/g, '&')
  re = /<pre><code>([\s\S]*?)<\/code><\/pre>/g
  results = str.match re
  if results
    _.each results, (result) ->
      highlightStr = hljs.highlight('javascript', result.substring 11, result.length - 13).value
      # console.dir appendLineNo highlightStr
      str = str.replace result, "<pre><code>#{appendLineNo(highlightStr)}</code></pre>"
    str
  else
    str
pageContentHandler = 
  index : (req, res, cbf) ->
    viewData =
      header : webConfig.getHeader req.url
    query = {}
    tag = req.params.tag
    query.tags = tag if tag
    async.parallel [
      (cbf) ->
        blogDbClient.find 'articles', {}, 'title authorInfo createdAt', {sort : [['createdAt', 'desc']]}, cbf
      (cbf) ->
        blogDbClient.find 'articles', query, {sort : [['createdAt', 'desc']]}, cbf
    ], (err, results) ->
      if err
        cbf err
        return
      viewData.articles = _.map results[1], (doc) ->
        arr = doc.content.split '\n'
        if arr.length > 15
          arr.length = 15
          doc.readMore = true
        ellipsisContent = arr.join '\n'

        doc.ellipsis = doc.content.length - ellipsisContent.length
        doc.content = highLight markdown.toHTML ellipsisContent
        doc.createdAt = new Date(doc.createdAt).toFormat 'YYYY.MM.DD'
        doc
      _.each results[0], (doc) ->
        doc.createdAt = new Date(doc.createdAt).toFormat 'YYYY.MM.DD'
      viewData.recommendations = results[0]
      cbf null, {
        title : 'javascript的淡望'
        viewData : viewData
      }
  article : (req, res, cbf) ->
    id = req.params.id
    record = 
      type : 'view'
      id : id
    statistics.record record
    blogDbClient.findById 'articles', id, (err, doc) ->
      if err
        cbf err
        return
      doc.content = highLight markdown.toHTML doc.content
      doc.createdAt = new Date(doc.createdAt).toFormat 'YYYY.MM.DD'
      viewData =
        header : webConfig.getHeader req.url
        article : doc
      cbf null, {
        title : doc.title
        viewData : viewData
      }
  saveArticle : (req, res, cbf) ->
    userInfo = req.session.userInfo
    if !userInfo || userInfo.level != 9
      res.redirect '/'
      return
    if req.xhr
      data = req.body
      if data
        id = req.params?.id
        if id
          data.modifiedAt = new Date()
          blogDbClient.findByIdAndUpdate 'articles', id, data, (err) ->
            if err
              result = 
                code : -1
                msg : 'modify artcile fail!'
            else
              result = 
                code : 0
                msg : 'modify artcile success!'
            cbf null, result
        else
          data.createdAt = new Date()
          data.authorInfo = userInfo
          blogDbClient.save 'articles', data, (err) ->
            if err
              result = 
                code : -1
                msg : 'save artcile fail!'
            else
              result = 
                code : 0
                msg : 'save artcile success'
            cbf null, result
      else
        cbf null, {
          code : -1
          msg : 'the data is null'
        }
    else
      viewData =
        header : webConfig.getHeader req.url
      if req.params?.id
        blogDbClient.findById 'articles', req.params.id, (err, doc) ->
          viewData.doc = doc
          cbf err, {
            title : '追逐javascript的灵魂精粹'
            viewData : viewData
          }
      else
        cbf null, {
          title : '追逐javascript的灵魂精粹'
          viewData : viewData
        }
  userInfo : (req, res, cbf) ->
    sess = req.session
    if req.method == 'POST'
      userInfo = req.body
      async.waterfall [
        (cbf) ->
          blogDbClient.find 'users', {id : userInfo.id}, cbf
        (info, cbf) ->
          if !info.length
            userInfo.createdAt = new Date()
            blogDbClient.save 'users', userInfo, (err) ->
              cbf err, userInfo
          else
            cbf null, info[0]
      ], (err, userInfo) ->
        if err
          cbf err
        else
          sess.userInfo = userInfo
          cbf null, {
            status : 1
          }
    else
      cbf null, _.omit sess.userInfo || {}, ['_id']
  statistics : (req, res, cbf) ->
    data = req.body
    if data
      data.userAgent = req.headers['user-agent']
      statistics.record data
      cbf null, {
        code : 0
        msg : 'success'
      }
    else
      cbf null, {
        code : -1
        msg : 'fail'
      }
  mergeAjax : (req, res, cbf) ->
    res.send [
      {
        code : 0
        msg : 'msg1'
      }
      {
        code : 0
        msg : 'msg2'
      }
    ]

module.exports = pageContentHandler
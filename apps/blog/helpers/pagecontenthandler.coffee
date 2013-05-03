_ = require 'underscore'

appConfig = require '../config'
appPath = appConfig.getAppPath()
webConfig = require "#{appPath}/helpers/webconfig"
markdown = require('markdown').markdown
async = require 'async'
hljs = require 'highlight.js'
fs = require 'fs'
blogDbClient = require('jtmongodb').getClient 'blog'
varnishHandler = require './varnishhandler'
statistics = require './statistics'

highLight = (str) ->
  appendLineNo = (code) ->
    codeList = code.split '\n'
    _.map(codeList, (code, i) ->
      "<span class='lineNo'>#{i + 1}</span>#{code}"
    ).join '\n'

  str = _.unescape(str).replace(/&#39;/g, "'").replace(/<script([\s\S]*?)<\/script>/g, '')
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
        title : 'Keep Coding, Cuttle Fish!'
        viewData : viewData
      }
      ids =  _.pluck viewData.articles, '_id'
      statistics.set 'view', ids
      statistics.set 'like', ids
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
        varnishHandler.refresh 'http://localhost/'
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
            title : 'Keep Coding, Cuttle Fish!'
            viewData : viewData
          }
      else
        cbf null, {
          title : 'Keep Coding, Cuttle Fish!'
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
  ask : (req, res, cbf) ->
    if req.method == 'GET'
      viewData =
        header : webConfig.getHeader req.url
        createdAt : new Date().toFormat 'YYYY.MM.DD'
      cbf null, {
        title : 'Keep Coding, Question!'
        viewData : viewData
      }
    else if req.method == 'POST'
      data = req.body
      userInfo = req.session.userInfo
      if !userInfo
        cbf null, {
          code : -1
          msg : '未登录'
        }
        return 
      data.createdAt = new Date()
      data.authorInfo = userInfo
      blogDbClient.save 'questions', data, (err) ->
        if err
          cbf null, {
            code : -1
            msg : 'success fail'
          }
        else
          cbf null, {
            code : 0
            msg : 'success'
          }
          varnishHandler.refresh 'http://localhost/questions'
  questions : (req, res, cbf) ->
    viewData =
      header : webConfig.getHeader req.url
    blogDbClient.find 'questions', {}, (err, docs) ->
      if err
        cbf err
        return
      questions = _.map docs, (doc) ->
        arr = doc.content.split '\n'
        if arr.length > 5
          arr.length = 5
        doc.readMore = true
        ellipsisContent = arr.join '\n'

        doc.ellipsis = doc.content.length - ellipsisContent.length
        doc.content = highLight markdown.toHTML ellipsisContent

        doc.createdAt = new Date(doc.createdAt).toFormat 'YYYY.MM.DD'
        doc
      viewData.questions = questions
      console.dir viewData
      cbf null, {
        title : 'Keep Coding, Cuttle Fish!'
        viewData : viewData
      }
  question : (req, res, cbf) ->
    id = req.params.id
    if req.method == 'GET'
      record = 
        type : 'view'
        id : id
      statistics.record record
      blogDbClient.findById 'questions', id, (err, doc) ->
        if err
          cbf err
          return
        doc.content = highLight markdown.toHTML doc.content
        doc.createdAt = new Date(doc.createdAt).toFormat 'YYYY.MM.DD'
        _.each doc.comments, (comment, i) ->
          comment.content = highLight markdown.toHTML comment.content
          comment.createdAt = new Date(comment.createdAt).toFormat 'YYYY.MM.DD'

        viewData =
          header : webConfig.getHeader req.url
          question : doc
        cbf null, {
          title : doc.title
          viewData : viewData
        }
    else
      data = req.body
      userInfo = req.session.userInfo
      if !userInfo || !data
        cbf null, {
          code : -1
          msg : 'fail'
        }
      else
        data.userInfo = userInfo
        data.createdAt = new Date()
        op = 
          '$push' : 
            comments : data
        blogDbClient.update 'questions', {_id : id}, op, (err) ->
          if err
            cbf null, {
              code : -1
              msg : 'fail'
            }
          else
            cbf null, {
              code : 0
              msg : 'success'
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
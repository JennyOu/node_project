_ = require 'underscore'

appConfig = require '../config'
appPath = appConfig.getAppPath()
webConfig = require "#{appPath}/helpers/webconfig"
markdown = require('markdown').markdown
async = require 'async'
hljs = require 'highlight.js'
fs = require 'fs'
vicansoDbClient = require('jtmongodb').getClient 'vicanso'


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
        vicansoDbClient.find 'articles', {}, 'title authorInfo createTime', {sort : [['createTime', 'desc']]}, cbf
      (cbf) ->
        vicansoDbClient.find 'articles', query, {sort : [['createTime', 'desc']]}, cbf
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
        doc.createTime = doc.createTime.toFormat 'YYYY.MM.DD'
        doc
      _.each results[0], (doc) ->
        doc.createTime = doc.createTime.toFormat 'YYYY.MM.DD'
      viewData.recommendations = results[0]
      cbf null, {
        title : 'javascript的淡望'
        viewData : viewData
      }
  article : (req, res, cbf) ->
    id = req.params.id
    vicansoDbClient.findById 'articles', id, (err, doc) ->
      if err
        cbf err
        return
      doc.content = highLight markdown.toHTML doc.content
      doc.createTime = doc.createTime.toFormat 'YYYY.MM.DD'
      viewData =
        header : webConfig.getHeader req.url
        article : doc
      cbf null, {
        title : doc.title
        viewData : viewData
      }
  saveArticle : (req, res, cbf) ->
    if req.xhr
      data = req.body
      if data
        # fs.writeFile './test.json', JSON.stringify(data), (err) ->
        data.createTime = new Date()
        data.authorInfo =
          name : '谢树洲Tree'
          contact : 'vicansocanbico@gmail.com'
          profilePic : 'http://tp1.sinaimg.cn/2398226332/50/5660016074/1'

        vicansoDbClient.save 'articles', data, (err) ->
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
      if req.level != 9
        res.redirect '/'
      else
        viewData =
          header : webConfig.getHeader req.url
        cbf null, {
          title : '追逐javascript的灵魂精粹'
          viewData : viewData
        }
  mergeAjax : (req, res, cbf) ->
    console.dir req.body
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
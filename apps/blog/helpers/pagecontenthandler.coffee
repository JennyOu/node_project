_ = require 'underscore'

appConfig = require '../config'
appPath = appConfig.getAppPath()
webConfig = require "#{appPath}/helpers/webconfig"

vicansoDbClient = require('jtmongodb').getClient 'vicanso'

# vicansoDbClient.findAndRemove 'articles', {_id : '513c42925447c7a103000002'}

pageContentHandler = 
  index : (req, res, cbf) ->
    viewData =
      header : webConfig.getHeader req.url
    vicansoDbClient.find 'articles', {}, (err, docs) ->
        if err
          cbf err
        else
          contentLengthLimit = 400
          results = [[], [], [], []]
          divideTotal = results.length
          _.each docs, (doc, i) ->
            content = doc.content
            itemContentLength = 0
            contentLimit = 0
            _.each content, (itemContent, i) ->
              if itemContentLength < contentLengthLimit
                itemContentLength += itemContent.value.length
                contentLimit = i
            if doc.content.length > contentLimit
              doc.content.length = contentLimit
            results[i % divideTotal].push doc
          viewData.articlesList = results
          cbf null, {
            title : '追逐javascript的灵魂精粹'
            viewData : viewData
          }
  article : (req, res, cbf) ->
    id = req.params.id
    vicansoDbClient.findById 'articles', id, (err, doc) ->
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
      viewData =
        header : webConfig.getHeader req.url
      cbf null, {
        title : '追逐javascript的灵魂精粹'
        viewData : viewData
      }

module.exports = pageContentHandler
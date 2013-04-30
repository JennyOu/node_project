jQuery ($) ->
  window.TIME_LINE.time 'runSaveArticleJs'
  restoreArtilce = () ->
    if window.ARTICLE
      data = window.ARTICLE
    else
      data = localStorage['savearticle']
      if !data
        return
      data = JSON.parse data
      if !data
        return
    articleContentObj = $ '.articleContent'
    content = data.title
    if data.title
      createConfig = 
        tip : '请输入标题：'
        itemClass : 'inputTitle'
        height : 30
      appendToEditItem createConfig, articleContentObj, content

    # _.each data.content, (item) ->
    #   content = item.value
    #   if item.tag == 'subtitle'
    #     createConfig = 
    #       tip : '请输入子标题：'
    #       itemClass : 'inputSubTitle'
    #       height : 30
    #   else if item.tag == 'code'
    #     createConfig = 
    #       tip : '请输入代码：'
    #       itemClass : 'inputCode'
    #       height : 120
    #   else if item.tag == 'content'
    #     createConfig = 
    #       tip : '请输入内容：'
    #       itemClass : 'inputContent'
    #       height : 600
    if data.content
      createConfig = 
        tip : '请输入内容：'
        itemClass : 'inputContent'
        height : 1800
      appendToEditItem createConfig, articleContentObj, data.content

  appendToEditItem = (createConfig, articleContentObj, content) ->
    $('<p />').html(createConfig.tip).appendTo articleContentObj
    editor = $('<textarea class="userTextArea" />').addClass(createConfig.itemClass).height(createConfig.height).appendTo articleContentObj
    if content
      editor.val content
    codeMirrorEditor = CodeMirror.fromTextArea editor.get(0), {
        lineNumbers: true
        theme : 'monokai'
        lineWrapping : true
      }
    editor.data 'codeMirrorEditor', codeMirrorEditor
    editor.next('.CodeMirror').find('.CodeMirror-scroll').height createConfig.height
    return editor

  $('.tags').on 'click', '.btn', (e, saveType) ->
    $(@).toggleClass 'selected'

  $('.controlBtns').on 'click', '.btn', (e, saveType) ->
    obj = $ @
    index = obj.index()
    switch index
      when 0 then createConfig = 
        tip : '请输入标题：'
        itemClass : 'inputTitle'
        height : 30
      # when 1 then createConfig = 
      #   tip : '请输入子标题：'
      #   itemClass : 'inputSubTitle'
      #   height : 30
      # when 3 then createConfig = 
      #   tip : '请输入代码：'
      #   itemClass : 'inputCode'
      #   height : 120
      when 2 then createConfig = null
      else createConfig = 
        tip : '请输入内容：'
        itemClass : 'inputContent'
        height : 1800
    articleContentObj = $ '.articleContent'
    if createConfig
      editor = appendToEditItem createConfig, articleContentObj
    else
      postData = {}
      content = []

      articleContentObj.find('.userTextArea').each () ->
        obj = $ @
        if obj.hasClass 'inputTitle'
          postData.title = obj.data('codeMirrorEditor').getValue()
        else if obj.hasClass 'inputSubTitle'
          tag = 'subtitle'
        else if obj.hasClass 'inputCode'
          tag = 'code'
        else
          tag = 'content'
        if tag
          content = obj.data('codeMirrorEditor').getValue()
      postData.content = content
      if saveType
        localStorage['savearticle'] = JSON.stringify postData
      else
        # localStorage['savearticle'] = null
        clearInterval autoSaveTimer
        postData.tags = $('.tags .btn.selected').map(() ->
          $(@).text()
        ).toArray()
        url = '/savearticle'
        if window.ARTICLE
          url = "#{url}/#{window.ARTICLE._id}"
        $.ajax({
          url : url
          type : 'post'
          data : postData
        }).success (data) ->
          if data.code == 0
            localStorage['savearticle'] = null
            alert '成功保存'
          else
            alert '保存失败'
          

  preview = () ->
    inputContentObj = $ '.articleContent .userTextArea.inputContent'
    if inputContentObj.length
      content = inputContentObj.data('codeMirrorEditor').getValue()
    inputTitleObj = $ '.articleContent .userTextArea.inputTitle'
    if inputTitleObj.length
      title = inputTitleObj.data('codeMirrorEditor').getValue()
    if content
      $('#contentContainer .preview .article .content').html markdown.toHTML content

      $('#contentContainer .preview .article .content pre code').each (i, e) ->
        hljs.highlightBlock e
    if title
      $('#contentContainer .preview .article .title a').html title
  restoreArtilce()
  preview()
  autoSaveTimer = setInterval () ->
    preview()
    $('.controlBtns .saveBtn').trigger 'click', ['localStorage']
  , 5000

  window.TIME_LINE.timeEnd 'runSaveArticleJs'
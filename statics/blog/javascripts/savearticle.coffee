jQuery ($) ->
  restoreArtilce = () ->
    data = localStorage['savearticle']
    if !data
      return
    data = JSON.parse data
    articleContentObj = $ '.articleContent'
    content = data.title
    if data.title
      createConfig = 
        tip : '请输入标题：'
        itemClass : 'inputTitle'
        height : 30
      appendToEditItem createConfig, articleContentObj, content

    _.each data.content, (item) ->
      content = item.value
      if item.tag == 'subtitle'
        createConfig = 
          tip : '请输入子标题：'
          itemClass : 'inputSubTitle'
          height : 30
      else if item.tag == 'code'
        createConfig = 
          tip : '请输入代码：'
          itemClass : 'inputCode'
          height : 120
      else if item.tag == 'content'
        createConfig = 
          tip : '请输入内容：'
          itemClass : 'inputContent'
          height : 60
      appendToEditItem createConfig, articleContentObj, content

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

  $('.controlBtns').on 'click', '.btn', (e, saveType) ->
    obj = $ @
    index = obj.index()
    switch index
      when 0 then createConfig = 
        tip : '请输入标题：'
        itemClass : 'inputTitle'
        height : 30
      when 1 then createConfig = 
        tip : '请输入子标题：'
        itemClass : 'inputSubTitle'
        height : 30
      when 3 then createConfig = 
        tip : '请输入代码：'
        itemClass : 'inputCode'
        height : 120
      when 4 then createConfig = null
      else createConfig = 
        tip : '请输入内容：'
        itemClass : 'inputContent'
        height : 60
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
          content.push {
            tag : tag
            value : obj.data('codeMirrorEditor').getValue()
          }
      postData.content = content
      if saveType
        localStorage['savearticle'] = JSON.stringify postData
      else
        localStorage['savearticle'] = null
        clearInterval autoSaveTimer
        $.ajax({
          url : '/savearticle'
          type : 'post'
          data : postData
        }).done (data) ->
          console.dir data

  restoreArtilce()
  autoSaveTimer = setInterval () ->
    ;
    # $('.controlBtns .saveBtn').trigger 'click', ['localStorage']
  , 2000
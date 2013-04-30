jQuery ($) ->
  editor = $ '#contentContainer .editor textarea'
  codeMirrorEditor = CodeMirror.fromTextArea editor.get(0), {
    lineNumbers: true
    theme : 'monokai'
    height : 600
    lineWrapping : true
  }
  editor.data('codeMirrorEditor', codeMirrorEditor).next('.CodeMirror').find('.CodeMirror-scroll').height 600

  $(document).on 'login', (e, data) ->
    author = $ '#contentContainer .preview .author'
    author.find('img').attr 'src', data.profilePic
    author.html "#{data.name}#{author.html()}"


  do () ->
    $('#contentContainer .editor .tags').on 'click', '.btn', () ->
      obj = $ @
      obj.toggleClass 'selected'
    $('#contentContainer .editor .submit').on 'click', () ->
      obj = $ @
      postData = getData()
      $.post('/ask', postData).success((data) ->
        if data.code == 0
          obj.text '已保存'
        else
          obj.text '保存失败'
      ).fail () ->
        obj.text '保存失败'

  getData = () ->
    title = $('#contentContainer .editor .title input').val()
    editor = $ '#contentContainer .editor textarea'
    tags = $('#contentContainer .editor .tags .selected').map () ->
      $(@).text()
    content = editor.data('codeMirrorEditor').getValue()
    {
      title : title
      tags : tags.toArray()
      content : content
    }




  preview = () ->
    data = getData()
    $('#contentContainer .preview .article .title').text data.title
    $('#contentContainer .preview .article .content').html markdown.toHTML data.content

  autoSaveTimer = setInterval () ->
    preview()
  , 5000
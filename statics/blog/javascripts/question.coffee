jQuery ($) ->

  getData = () ->
    codeMirrorEditor =  $('#leftContainer .replyContainer .replyContent textarea').data 'codeMirrorEditor'
    codeMirrorEditor.getValue()
  prevView = () ->
    $('#leftContainer .preview .content').html markdown.toHTML getData()
  do () ->
    $(document).on 'login', (e, userInfo) ->
      questionObj = $ '#leftContainer .questionContainer .question'
      questionTitle = questionObj.attr 'title'
      author = $ '#leftContainer .replyContainer .author'
      author.html "#{userInfo.name}回复(#{questionTitle})：<a class='reply' href='javascript:;'>确定回复</a><img src='#{userInfo.profilePic}' />"
      author.on 'click', '.reply', () ->
        obj = $ @
        $.ajax({
          url : "/question/#{questionObj.attr('data-id')}"
          data : 
            content : getData()
          type : 'post'
        }).success (data) ->
          if data.code == 0
            obj.text '回复成功！'
          else
            obj.text '回复失败！'
      editor = $('<textarea />').appendTo $ '#leftContainer .replyContainer .replyContent'
      codeMirrorEditor = CodeMirror.fromTextArea editor.get(0), {
        lineNumbers: true
        theme : 'monokai'
        height : 60
        lineWrapping : true
      }
      editor.data('codeMirrorEditor', codeMirrorEditor).next('.CodeMirror').find('.CodeMirror-scroll').height 60

      setInterval prevView, 3000


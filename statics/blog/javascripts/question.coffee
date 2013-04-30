jQuery ($) ->


  do () ->
    $(document).on 'login', (e, userInfo) ->
      questionTitle = $('#leftContainer .questionContainer .question').attr 'title'
      author = $ '#leftContainer .replyContainer .author'
      author.html "#{userInfo.name}回复(#{questionTitle})：<a class='reply' href='javascript:;'>确定回复</a><img src='#{userInfo.profilePic}' />"
      editor = $('<textarea />').appendTo $ '#leftContainer .replyContainer .replyContent'
      codeMirrorEditor = CodeMirror.fromTextArea editor.get(0), {
        lineNumbers: true
        theme : 'monokai'
        height : 60
        lineWrapping : true
      }
      editor.data('codeMirrorEditor', codeMirrorEditor).next('.CodeMirror').find('.CodeMirror-scroll').height 60



      # <div class="author">谢树洲Tree的提问：<a href="/question/517a75e70ff5197d02000001" target="_blank" class="title">怎么测试node</a><span class="createTime">2013.04.26</span><img src="http://tp1.sinaimg.cn/2398226332/30/5660016074/1"></div>


# id: "sinaweibo_2398226332"
# level: 9
# location: "广东 广州"
# name: "谢树洲Tree"
# profilePic: "http://tp1.sinaimg.cn/2398226332/30/5660016074/1"
# profileUrl: "http://weibo.com/u/2398226332"

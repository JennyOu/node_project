window.TIME_LINE.timeEnd 'loadjs'
window.TIME_LINE.time 'execjs'
jQuery ($) ->
  _ = window._
  async = window.async

  addModifyBtn = () ->
    $('.article').each () ->
      obj = $ @
      id = obj.attr 'data-id'
      obj.find('.behaviorBtns').append "<a class='btn', href='/savearticle/#{id}', target='_blank'>修改</a>"
  postUserInfo = (userInfo) ->
    $.post('/userinfo?cache=false', userInfo).success () ->
      console.dir arguments

  appendWeiboLogin = (id, cbf) ->
    async.waterfall [
      (cbf) ->
        $.getScript('http://tjs.sjs.sinajs.cn/open/api/js/wb.js?appkey=4276143701').success () ->
            cbf null
      (cbf) ->
        WB2.anyWhere (W) ->
          cbf null, W
      (W, cbf) ->
        W.widget.connectButton {
          id : 'weiboLogin'
          type : '4,2'
          callback : 
            login : (o) ->
              userInfo = 
                name : o.name
                profilePic : o.profile_image_url.replace '/50/', '/30/'
                id : "sinaweibo_#{o.id}"
                location : o.location
                profileUrl : "http://weibo.com/#{o.profile_url}"
              cbf null, userInfo

        }
    ], cbf

  $.get('/userinfo?test=1&cache=false').success (userInfo) ->
    if !userInfo.id
      appendWeiboLogin 'weiboLogin', (err, userInfo) ->
        if !err && userInfo
          postUserInfo userInfo
    else
      $('#weiboLogin').html "<div class='userInfoContainer'><a href='#{userInfo.profileUrl}'>#{userInfo.name}</a>(已登录)</div>"
      if userInfo.level == 9
        addModifyBtn()
  # init event
  do () ->
    $('#goToTop').click () ->
      $('html, body').animate {
        scrollTop : 0
      }, 200

    $('.article .behaviorBtns').on 'click', '.like', () ->
      id = $(@).closest('.article').attr 'data-id'
      data = 
        type : 'like'
        id : id
      $.post '/statistics', data

  window.TIME_LINE.timeEnd 'all', 'html'
  setTimeout () ->
    data = window.TIME_LINE.getLogs()
    data.type = 'timeline'
    $.post '/statistics', data
  , 0



# window.TIME_LINE = 
#   logs : {}
#   startTimes : {}
#   time : (tag) ->
#     @startTimes[tag] = new Date().getTime();
#     @
#   timeEnd : (tag, startTag) ->
#     startTimes = @startTimes
#     start = startTimes[tag] || startTimes[startTag]
#     if start
#       @logs[tag] = new Date().getTime() - start
#     @
#   getLogs : () ->
#     @logs

ManagementPage = Backbone.View.extend {
  events : 
    'click .functions .addUser' : 'addUser'
  userLogin : (userInfo) ->
    functions = @$el.find '.functions'
    if userInfo.permissions > 5
      functions.children().show()
    else if userInfo.permissions > 2
      functions.children(':not(".addUser")').show()
    else if userInfo.permissions > 0
      functions.children('.sell').show()
    else
      functions.children().hide()
  initialize : ->
    self = @
    $(document).on 'userinfo', (e, userInfo) ->
      self.userLogin userInfo
  addUser : ->
    async.waterfall [
      (cbf) ->
        if window.CryptoJS
          cbf null, window.CryptoJS
        else
          $.getScript('/statics/common/javascripts/utils/sha1.min.js').success () ->
            cbf null, window.CryptoJS
      (CryptoJS, cbf) ->
        html = '<div class="addUserContainer">' +
          '<input type="text" class="name" placeholder="请输入用户名" /><br />' + 
          '<input type="password" class="pwd" placeholder="请输入密码" /><br />' +
          '<input type="password" class="confirmPwd" placeholder="请确认输入密码" />' +
          '<p class="errorText infoTip"></p>' +
        '</div>'
        new JT.View.Alert 
          model : new JT.Model.Dialog
            title : '创建用户'
            content : html
            btns : 
              '创建' : ($el)->
                name = $el.find('.name').val()
                pwd = $el.find('.pwd').val()
                confirmPwd = $el.find('.confirmPwd').val()
                errMsg = []
                if !name
                  errMsg.push '用户名为空！'
                if !pwd
                  errMsg.push '密码为空！'
                if pwd != confirmPwd
                  errMsg.push '两次输入的密码不相同！'
                if errMsg.length
                  $el.find('.infoTip').text errMsg.join ''
                  false
                else 
                  cbf null, {
                    name : name
                    pwd : CryptoJS.SHA1(pwd).toString()
                  }
              '取消' : ->
                cbf null, null
      (data, cbf) ->
        if !data
          cbf null, null
        else
          $.post('/adduser', data).success (data) ->
            cbf null, data
    ], (err, data) ->
      if err
        msg = err.msg || err.toString()
      else if data
        msg = data.msg
      if msg
        new JT.View.Alert
          model : new JT.Model.Dialog
            title : '创建用户'
            content : msg
            btns : 
              '确定' : ->
}

jQuery ($) ->
  _ = window._
  async = window.async

  window.TIME_LINE.timeEnd 'all', 'html'
  new ManagementPage {
    el : document
  }
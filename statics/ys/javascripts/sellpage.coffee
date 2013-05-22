SellPage = Backbone.View.extend {
  events :
    'click .save' : 'save'
    'click .saveToTemp' : 'saveToTemp'
    'click .print' : 'print'
    'click .getOrderNo' : 'getOrderNo'
  print : ->
    @printTable.update @getData()
    window.print()
  userLogin : (userInfo) ->
    if userInfo.permissions > 1
      @$el.show()
  getOrderNo : ->
    self = @
    $.get('/orderno?type=xs&cache=false').success (data) ->
      if data.orderNo
        self.setOrderNo data.orderNo
  setOrderNo : (number) ->
    @$el.find('.sellOrderNo span').text number
  getData : ->
    $el = @$el
    data =
      type : 'sell'
      id : $el.find('.sellOrderNo span').text()
      depot : @depotSelect.val()
      client : @clientSelect.val()
      payType : @payTypeSelect.val()
    data = _.extend data, @sellItemListView.val()
  saveToTemp : ->
    @post '/tempsave'
  save : ->
    @post '/save'
  post : (url = '/save') ->
    self = @
    data = @getData()
    @validate data, (err) ->
      if !err
        if window.SELL_DATA
          data._id = window.SELL_DATA._id
        $.post(url, data).success (data) ->
          if data.code == 0
            new JT.View.Alert
              model : new JT.Model.Dialog
                title : '保存成功'
                content : '<p>保存成功，3秒后自动刷新页面！</p>'
                btns : 
                  '直接刷新' : ->
                    window.location.href = '/sell'
            _.delay () ->
              window.location.href = '/sell'
            , 3000
          else
            new JT.View.Alert 
              model : new JT.Model.Dialog
                title : '保存失败'
                content : '<p>保存失败，请重新保存！</p>'
                btns : 
                  '保存' : ->
                    self.post url
                  '取消' : ->

  validate : (data, cbf)->
    errorMsg = []
    if !data.depot
      errorMsg.push '<p class="errorText">出货仓库未选择，请先选择！</p>'
    if !data.client
      errorMsg.push '<p class="errorText">销售客户未选择，请先选择！</p>'
    if !data.payType
      errorMsg.push '<p class="errorText">付款类型未选择，请先选择！</p>'
    if !data.inputPriceTotal || Math.abs(data.inputPriceTotal - data.priceTotal) > 10
      errorMsg.push '<p class="errorText">输入金额为0或者与实际金额相差太大，请确认是否有误！</p>'
    if !errorMsg.length
      cbf null
    else
      new JT.View.Alert
        model : new JT.Model.Dialog
          title : '销售单数据有误'
          content : errorMsg.join ''
          btns : 
            '继续保存' : ->
              cbf null
            '取消保存' : ->
  initialize : ->
    self = @
    $el = @$el
    $(document).on 'userinfo', (e, userInfo) ->
      self.userLogin userInfo
    @selectItemListDialog = new JT.View.Dialog {
      el : $el.find('.selectItemsContainer').get 0
      model : new JT.Model.Dialog
        title : '商品选择列表'
        btns : 
          '确定' : () ->
            self.selectItemListView.select()
          '关闭' : () ->
    }

    @sellItemListView = new YS.OrderItemListView {
      el : $el.find('.sellItemsContainer').get 0
      model : new YS.OrderItemList
      showSelectList : (key) ->
        self.selectItemListDialog.open()
        self.selectItemListView.show key.trim(), self.depotSelect.val()
    }
    @selectItemListView = new YS.SelectItemListView {
      el : $el.find('.selectItemsContainer .content').get 0
      model : new YS.SelectItemList
      select : (data) ->
        self.selectItemListDialog.close()
        self.sellItemListView.add data
    }

    @depotSelect = new JT.Collection.Select DEPOTS
    new JT.View.Select {
      el : $el.find '.depot'
      tips : '出货仓库'
      model : @depotSelect
    }

    @clientSelect = new JT.Collection.Select [
        {
          key : '珠海刘'
          name : '珠海刘'
        }
        {
          key : '珠海郑'
          name : '珠海郑'
        }
        {
          key : '珠海谢'
          name : '珠海谢'
        }
      ]
    new JT.View.Select {
      el : $el.find '.client'
      tips : '客户选择'
      model : @clientSelect
    }

    @payTypeSelect = new JT.Collection.Select [
        {
          key : '已付'
          name : '已付'
        }
        {
          key : '汇款'
          name : '汇款'
        }
        {
          key : '送货收钱'
          name : '送货收钱'
        }
      ]
    new JT.View.Select {
      el : $el.find '.payType'
      tips : '付款类型'
      model : @payTypeSelect
    }

    @printTable = new PrintTable {
      el : $('#printContainer').get 0
    }

    if window.SELL_DATA
      @depotSelect.val window.SELL_DATA.depot
      @clientSelect.val window.SELL_DATA.client
      @payTypeSelect.val window.SELL_DATA.payType
      @sellItemListView.val window.SELL_DATA
      @setOrderNo window.SELL_DATA.id
    else
      @getOrderNo()
}


PrintTable = Backbone.View.extend {
  infoTemplate : _.template '<div class="info">' +
    '<div class="item">出货仓库：<span><%= depot %></span></div>' +
    '<div class="item">客户：<span><%= client %></span></div>' +
    '<div class="item">付款类型：<span><%= payType %></span></div>' +
    '<div class="item">销售单编号：<span><%= id %></span></div>' +
  '</div>'
  trTemplate : _.template '<tr>' +
    '<td><%= name %></td>' +
    '<td><%= barcode %></td>' +
    '<td><%= size %></td>' +
    '<td><%= count %></td>' +
    '<td><%= auxiliaryCount %></td>' +
    '<td><%= price %></td>' +
    '<td><%= priceTotal %></td>' +
  '</tr>'

  tableTemplate : _.template '<table class="printTable">' +
    '<thead><tr><th class="name">商品名</th><th class="barcode">条码</th><th class="size">规格</th><th class="count">数量</th><th class="auxiliaryCount">辅助数量</th><th class="price">单价</th><th class="priceTotal">总价</th></tr></thead>' +
    '<tbody><%= tbody %></tbody>' +
  '</table>'
  initialize : ->

  update : (data) ->
    trTemplate = @trTemplate
    infoHtml = @infoTemplate data
    trHtmlArr = _.map data.items, (item) ->
      trTemplate item
    tableHtml = @tableTemplate {tbody : trHtmlArr.join ''}
    @$el.html infoHtml + tableHtml
}

jQuery ($) ->
  sellPage = new SellPage
    el : $('#sellPageContainer').get 0
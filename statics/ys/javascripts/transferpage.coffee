TransferPage = Backbone.View.extend {
  events : 
    'click .save' : 'save'
    'click .getOrderNo' : 'getOrderNo'
  getData : ->
    $el = @$el
    data = 
      type : 'transfer'
      id : $el.find('.transferOrderNo span').text()
      fromDepot : @fromDepotSelect.val()
      toDepot : @toDepotSelect.val()
    items = @transferItemsListView.val().items
    data.items = _.map items, (item) ->
      _.omit item, ['buyPrice', 'price', 'priceTotal']
    data
  userLogin : (userInfo) ->
    if userInfo.permissions > 4
      @$el.show()
  getOrderNo : ->
    $el = @$el
    $.get('/orderno?type=zc&cache=false').success (data) ->
      if data.orderNo
        $el.find('.transferOrderNo span').text data.orderNo
  save : ->
    data = @getData()
    @validate data, (err) ->
      if !err
        $.post('/save', data).success (data) ->
          if data.code == 0
            new JT.View.Alert 
              model : new JT.Model.Dialog
                title : '保存成功'
                content : '<p>保存成功，3秒后自动刷新页面！</p>'
                btns : 
                  '直接刷新' : ->
                    window.location.reload()
            _.delay () ->
              window.location.reload()
            , 3000
          else
            new JT.View.Alert 
              model : new JT.Model.Dialog
                title : '保存失败'
                content : '<p>保存失败，请重新保存！</p>'
                btns : 
                  '保存' : ->
                    self.save()
                  '取消' : ->
  validate : (data, cbf)->
    errorMsg = []
    if !data.fromDepot
      errorMsg.push '<p class="errorText">转出仓库未选择，请先选择！</p>'
    if !data.toDepot
      errorMsg.push '<p class="errorText">转入仓库未选择，请先选择！</p>'
    if data.fromDepot && data.fromDepot == data.toDepot
      errorMsg.push '<p class="errorText">转出和转入仓库相同，请修改！</p>'
    if !data.items.length
      errorMsg.push '<p class="errorText">未选择转出商品，请选择！</p>'
    if !errorMsg.length
      cbf null
    else
      new JT.Alert
        model : new JT.Model.Dialog
          title : '转仓单数据有误'
          content : errorMsg.join ''
          btns : 
            '确定' : ->
  initialize : ->
    self = @
    $el = @$el
    $(document).on 'userinfo', (e, userInfo) ->
      self.userLogin userInfo
      
    @selectItemListDialog = new JT.View.Dialog
      el : $el.find('.selectItemsContainer').get 0
      model : new JT.Model.Dialog
        title : '商品选择列表'
        btns : 
          '确定' : () ->
            self.selectItemListView.select()
          '关闭' : () ->

    @transferItemsListView = new YS.OrderItemListView
      el : $el.find('.transferItemsContainer').get 0
      model : new YS.OrderItemList
      showSelectList : (key) ->
        self.selectItemListDialog.open()
        self.selectItemListView.show key.trim(), self.fromDepotSelect.val()
    @selectItemListView = new YS.SelectItemListView
      el : $el.find('.selectItemsContainer .content').get 0
      model : new YS.SelectItemList
      select : (data) ->
        self.selectItemListDialog.close()
        self.transferItemsListView.add data


    @fromDepotSelect = new JT.Collection.Select DEPOTS
    new JT.View.Select
      el : $el.find '.fromDepot'
      tips : '转出仓库'
      model : @fromDepotSelect


    @toDepotSelect = new JT.Collection.Select DEPOTS
    new JT.View.Select
      el : $el.find '.toDepot'
      tips : '转入仓库'
      model : @toDepotSelect

    @getOrderNo()
}

jQuery ($) ->
  transferPage = new TransferPage
    el : $('#transferPageContainer').get 0
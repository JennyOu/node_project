window.YS ?= {}
$ = window.jQuery

YS.SelectItem = YS.BaseItem.extend {
}
YS.SelectItemList = Backbone.Collection.extend {
  model : YS.SelectItem
}

YS.SelectItemListView = YS.ItemListView.extend {
  events : 
    'dblclick .item' : 'itemDblClick'
    'click .item' : 'itemClick'
  fields : [
    {
      name : '#'
      className : 'op'
      html : '<a href="javascript:;" class="check icon iBorder"></a>'
    }
    {
      name : '商品名'
      className : 'name'
      html : '<%= name %>'
    }
    {
      name : '条码'
      className : 'barcode'
      html : '<%= barcode %>'
    }
    {
      name : '规格'
      className : 'size'
      html : '<%= size %>'
    }
    {
      name : '库存'
      className : 'stock'
      html : '<%= stock %>'
    }
  ]
  initialize : ->
    @template = @getTemplate()
    @$el.addClass 'selectItemTable itemTable'
    @render()
  itemDblClick : (e) ->
    obj = $ e.currentTarget
    @getSelectData [obj.index()]
    @
  itemClick : (e) ->
    obj = $ e.currentTarget
    obj.find('.check').toggleClass 'iOk iBorder'
    @
  select : ->
    $el = @$el
    indexArr = []
    $el.find('.item .check.iOk').each () ->
      obj = $ @
      indexArr.push obj.closest('.item').index()
    @getSelectData indexArr
    @
  getSelectData : (indexArr) ->
    model = @model
    selectedData = []
    _.each indexArr, (index) ->
      item = model.at index
      if item
        selectedData.push item.toJSON()
    @options.select selectedData
    @
  data : (key, stockName) ->
    self = @
    if self.ajax
      self.ajax.abort()
    async.waterfall [
      (cbf) ->
        self.ajax = $.get('./items').success (data) ->
          if data.code != 0
            err = new Error
            err.msg = data.msg
            data = null
          else
            data = data.data
          cbf err, data
        .fail () ->
          self.ajax = null
          err = new Error
          err.msg = '请求数据失败！'
          cbf err
    ], (err, items) ->
      if err
        new JT.Alert {
          title : '出错！'
          content : "<p>#{err.msg}</p>"
          btns : 
            '确定' : ->
        }
      else
        _.each items, (item) ->
          if stockName
            item.stock = item.stocksForecast[stockName]
          else
            item.stock = ''
        self.model.reset items
        self.render()
    @
  show : () ->
    @$el.show()
    @data.apply @, arguments
    @
  reset : ->
    @$el.hide().find('.item .check.iOk').toggleClass 'iOk iBorder'
    @
  render : ->
    self = @
    tableHtml = @getTableHtml()
    @$el.html tableHtml
    @
}
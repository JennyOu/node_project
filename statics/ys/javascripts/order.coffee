window.YS ?= {}
$ = window.jQuery

YS.OrderItem = YS.BaseItem.extend {
  defaults:
    price : 1
    count : 1
    auxiliaryCount : ''
    priceTotal : ''
  initialize : ->
    @changeCount @, @get 'count'
    @changePrice @, @get 'price'
    @on 'change:count', @changeCount
    @on 'change:price', @changePrice
  changeCount : (model, value) ->
    unitRelation = model.get 'unitRelation'
    oldValue = value
    value = window.parseInt value
    if _.isNaN value
      value = model.previous 'count'
    if oldValue != value
      model.set 'count', value
      return
    price = model.get 'price'
    packTotal = Math.floor value / unitRelation
    unitTotal = value % unitRelation
    auxiliaryCount = ''
    if packTotal
      auxiliaryCount = "#{packTotal}#{model.get('auxiliaryUnit')}"
    if unitTotal
      auxiliaryCount += "#{unitTotal}#{model.get('unit')}"
    model.set 'auxiliaryCount', auxiliaryCount
    if price
      @changePrice model, price
    @
  changePrice : (model, value) ->
    oldValue = value
    value = window.parseFloat value
    if _.isNaN value
      value = model.previous 'price'
    if oldValue != value
      model.set 'price', value
      return 
    count = model.get 'count'
    if count
      model.set 'priceTotal', window.parseFloat (count * value).toFixed 2
    @
}

YS.OrderItemList = Backbone.Collection.extend {
  model : YS.OrderItem
}

YS.OrderItemListView = YS.ItemListView.extend {
  events : 
    'dblclick .showSelectList' : 'showSelectList'
    'focus input.userInput' : 'userInputFocus'
    'focus .ctrls .showSelectList' : 'showSelectListFocus'
    'blur input.userInput' : 'userInputBlur'
    'change input.userInput' : 'userInputChange'
    'click .remove' : 'removeClick'
    'keyup .showSelectList' : 'showSelectListKeyup'
  fields : [
    {
      name : '#'
      className : 'op'
      html : '<a class="remove icon iRemove" href="javascript:;" title="从表格删除该项"></a>'
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
      name : '数量'
      className : 'count'
      html : '<input type="text" placeholder="商品购买数量" data-key="count" value=<%= count %> class="userInput" />'
    }
    {
      name : '辅助数量'
      className : 'auxiliaryCount'
      html : '<%= auxiliaryCount %>'
    }
    {
      name : '单价'
      className : 'price'
      html : '<input type="text" placeholder="商品购买单价" data-key="price" value=<%= price %> class="userInput" />'
    }
    {
      name : '总价'
      className : 'priceTotal'
      html : '<%= priceTotal %>'
    }
  ]
  initialize : ->
    @template = @getTemplate()
    @$el.addClass 'orderItemTable itemTable'
    @model.bind 'add', @render, @
    @render()
  userInputFocus : (e) ->
    obj = $ e.currentTarget
    obj.data 'prevValue', obj.val()
    obj.val ''
    @
  userInputBlur : (e) ->
    obj = $ e.currentTarget
    value = obj.val().trim()
    if !value
      obj.val obj.data 'prevValue'
    @
  userInputChange : (e) ->
    obj = $ e.currentTarget
    trObj = obj.closest 'tr'
    index = trObj.index()
    key = obj.attr 'data-key'
    data = {}
    data[key] = obj.val().trim()
    @async data, index
    @
  showSelectListFocus : (e) ->
    obj = $ e.currentTarget
    obj.val ''
    @
  removeClick : (e) ->
    obj = $ e.currentTarget
    index = obj.closest('tr').index()
    @remove index
    @
  showSelectListKeyup : (e) ->
    if e.keyCode == 0x0d
      @showSelectList()
    @
  showSelectList : ->
    @options.showSelectList @$el.find('.showSelectList').val()
    @
  add : (data) ->
    if data
      @model.add data
    @
  update : ->
    model = @model
    $el = @$el
    itemObjs = $el.find '.item'
    for i in [0...model.length]
      itemObj = itemObjs.eq i
      item = model.at i
      priceObj = itemObj.find '.price .userInput'
      price = item.get 'price'
      if price < item.get 'buyPrice'
        priceObj.addClass 'warning'
      else
        priceObj.removeClass 'warning'
      priceObj.val price
      itemObj.find('.count .userInput').val item.get 'count'
      itemObj.find('.auxiliaryCount').text item.get 'auxiliaryCount'
      itemObj.find('.priceTotal').text item.get 'priceTotal'
    $el.find('.priceTotal span').text @getPriceTotal @model.toJSON()
    @
  val : (value) ->
    $el = @$el
    priceTotalInput = $el.find '.priceTotal .confirmTotalPrice'
    remarkInput = $el.find '.remark input'
    if !value
      items = @model.toJSON()
      inputPriceTotal = window.parseFloat priceTotalInput.val()
      if _.isNaN inputPriceTotal
        inputPriceTotal = 0
      data =
        priceTotal : @getPriceTotal items
        profitTotal : @getProfitTotal items
        inputPriceTotal : inputPriceTotal
        remark : remarkInput.val()
        items : items
    else
      priceTotalInput.val value.inputPriceTotal
      remarkInput.val value.remark
      @add value.items
  getPriceTotal : (items) ->
    priceTotalList = _.pluck items, 'priceTotal'
    priceTotal = _.reduce priceTotalList, (memo, priceTotal) ->
      memo + window.parseFloat priceTotal
    , 0
    window.parseFloat priceTotal.toFixed 2
  getProfitTotal : (items) ->
    profitTotal = _.reduce items, (memo, item) ->
      profit = (item.price - item.buyPrice) * item.count
      memo + window.parseFloat profit
    , 0
    window.parseFloat profitTotal.toFixed 2
  render : ->
    self = @
    $el = @$el
    items = @model.toJSON()
    tableHtml = @getTableHtml 5
    priceTotal = @getPriceTotal items
    ctrlHtml = '<div class="ctrls"><input type="text" class="showSelectList borderRadius5" placeholder="双击显示商品列表，可输入筛选条件" /></div>'

    priceTotalHtml = "<div class='priceTotal'>总价：<span>#{priceTotal}</span>元<input type='text' placeholder='请确认输入总价' class='confirmTotalPrice borderRadius5' /></div>"
    remarkHtml = "<div class='remark'>备注：<input type='text' placeholder='请输入备注信息' class='borderRadius5' /></div>"
    othersHtml = "<div class='othersInfo'>#{priceTotalHtml}#{remarkHtml}#{ctrlHtml}</div>"
    $el.html "#{tableHtml}#{othersHtml}"
    $el.find('.tbodyContainer').scrollTop 99999
    @
}
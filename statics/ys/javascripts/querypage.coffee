QueryListView = YS.ItemListView.extend {
  fields : [
    {
      name : '#'
      className : 'op'
      html : '<a class="edit icon iDocument" href="<%= type %>/<%= _id %>" title="编辑该草稿单" target="_blank"></a>'
    }
    {
      name : '编号'
      className : 'orderId'
      html : '<%= id %>'
    }
    {
      name : '操作员'
      className : 'oper'
      html : '<%= oper %>'
    }
    {
      name : '单据类型'
      className : 'type'
      html : '<%= typeView %>'
    }
    {
      name : '客户'
      className : 'client'
      html : '<%= client %>'
    }
    {
      name : '付款方式'
      className : 'payType'
      html : '<%= payType %>'
    }
    {
      name : '总价（元）'
      className : 'priceTotal'
      html : '<%= inputPriceTotal %>'
    }
    {
      name : '利润（元）'
      className : 'profitTotal'
      html : '<%= profitTotal %>'
    }
    {
      name : '备注'
      className : 'remark'
      html : '<%= remark %>'
    }
    {
      name : '创建时间'
      className : 'createdAt'
      html : '<%= createdAt %>'
    }
  ]
  reset : (data) ->
    if data
      types =
        sell : '销售单'
        buy : '进货单'
        transfer : '转仓单'
      _.each data, (item) ->
        type = types[item.type]
        item.typeView = type || item.type
        item.payType ?= ''
        item.profitTotal ?= ''
        item.remark ?= ''
      @model.reset data
    @
  initialize : ->
    @template = @getTemplate()
    @$el.addClass 'queryItemTable itemTable'
    @model.bind 'reset', @render, @
    @render()
  render : ->
    @$el.html @getTableHtml()
}
QueryList = Backbone.Collection.extend {
  model : YS.BaseItem
}


QueryPage = Backbone.View.extend {
	events :
  	'click .search' : 'search'
  search : ->
    self = @
    $el = @$el
    fromDate = $el.find('.fromDate').val()
    toDate = $el.find('.toDate').val()
    type = $el.find('.typeSelect :checked').val()
    collections = 
      '草稿' : 'drafts'
      '已存单据' : 'orders'
    $.get('/search', {from : fromDate, to : toDate, cache : false, collection : collections[type]}).success (data) ->
      docs = data.data
      if type == '草稿' && self.hideProfitTotal
        _.each docs, (doc) ->
          doc.profitTotal = ''
      self.queryListView.reset docs
      if !docs.length
        new JT.Alert {
          title : '提示信息'
          content : '该时间段的单据为空，请确认选择的时间是否有误！'
        }
  userLogin : (userInfo) ->
    if userInfo.permissions > 1
      $el = @$el
      $el.show()
      today = new Date()
      yesterday = new Date today.getTime() - 24 * 3600 * 1000
      new JT.DatePicker {
        el : $el.find('.fromDate').get 0
        date : yesterday
      }
      new JT.DatePicker {
        el : $el.find('.toDate').get 0
        date : today
      }
      if userInfo.permissions < 7
        @hideProfitTotal = true
        $el.find('.typeSelect .order').hide()
  initialize : ->
    self = @
    $el = @$el
    $(document).on 'userinfo', (e, userInfo) ->
      self.userLogin userInfo

    $el.find('.typeSelect :radio:first').prop 'checked', true

    @queryListView = new QueryListView {
      el : $el.find('.tableView').get 0
      model : new QueryList
    }
}


jQuery ($) ->
  new QueryPage
    el : $('#queryPageContainer').get 0
window.JT ?= {}
JT.Model ?= {}
JT.View ?= {}
JT.Collection ?= {}
$ = window.jQuery
JT.VERSION = '0.0.1'

JT.Model.Select = Backbone.Model.extend {}

JT.Collection.Select = Backbone.Collection.extend {
  model : JT.Model.Select
}

JT.View.Select = Backbone.View.extend {
  template : _.template '<div class="jtSelect jtBorderRadius3">' +
    '<a href="javascript:;" class="showSelect jtGrayGradient"><span class="jtArrowDown"></span></a>' +
    '<input class="userInput" type="text" title="<%= tips %>" placeholder="<%= tips %>" />' +
    '<ul class="selectList"><%= list %></ul>' +
  '</div>'
  events :
    'click .showSelect' : 'toggleSelect'
    'keyup .userInput' : 'userInput'
    'dblclick .userInput' : 'dblclickUserInput'
    'click .option' : 'select'
  userInput : (e) ->
    if e.keyCode == 0x0d
      @show @$el.find '.selectList'
    else if e.keyCode == 0x1b
      @hide @$el.find '.selectList'
    @
  toggleSelect : ->
    $el = @$el
    selectList = $el.find '.selectList'
    if selectList.is ":hidden"
      $el.find('.userInput').val ''
      @show selectList
    else
      @hide selectList
    @
  dblclickUserInput : ->
    $el = @$el
    $el.find('.userInput').val ''
    @show $el.find '.selectList'
  val : (value) ->
    $el = @$el
    userInput = $el.find '.userInput'
    returnValue = ''
    if !value
      value = userInput.val()
      $el.find('.option').each () ->
        obj = $ @
        if !returnValue && obj.text() == value
          returnValue = obj.attr 'data-key'
      returnValue
    else
      $el.find('.option').each () ->
        obj = $ @
        if !returnValue && obj.attr('data-key') == value
          returnValue = obj.text()
      userInput.val returnValue
      @
  show : (selectList) ->
    selectList ?= @$el.find '.selectList'
    @filter()
    @$el.find('.showSelect span').removeClass('jtArrowDown').addClass 'jtArrowUp'
    selectList.show()
    @
  hide : (selectList) ->
    @reset()
    @$el.find('.showSelect span').removeClass('jtArrowUp').addClass 'jtArrowDown'
    selectList.hide()
    @
  filter : ->
    $el = @$el
    key = $el.find('.userInput').val().trim()
    options = $el.find '.selectList .option'
    if key
      options.each (i, option) ->
        option = $ option
        value = option.text()
        if !~value.indexOf key
          option.hide()
    else
      options.show()
    @
  reset : ->
    @$el.find('.selectList .option').show()
    @
  select : (e) ->
    obj = $ e.currentTarget
    @$el.find('.userInput').val obj.text()
    @toggleSelect()
    @
  destroy : ->
    @remove()
    @$el.remove()
  initialize : ->
    self = @
    @$el.addClass 'jtWidget'
    @listenTo @model, "all", (event) ->
      if !~event.indexOf ':'
        self.render()
    @render()
    @
  render : ->
    listHtmlArr = _.map @model.toJSON(), (item) ->
      if _.isObject item
        name = item.name
        key = item.key
      else
        name = item
        key = item
      "<li class='option' data-key='#{key}'>#{name}</li>"
    @templateData = 
      tips : @options.tips
      list : listHtmlArr.join ''
    html = @template @templateData
    @$el.html html
    @
}


JT.Model.Dialog = Backbone.Model.extend {
  defaults : 
    title : '未命名标题'
    content : '未定义内容'
    destroyOnClose : true
}
JT.View.Dialog = Backbone.View.extend {
  template : _.template '<h3 class="title jtBlueGradient jtBorderRadius3"><a href="javascript:;" class="close">×</a><%= title %></h3>' +
    '<div class="content"><%= content %></div>' + 
    '<%= btns %>'
  events : 
    'click .btns .btn' : 'btnClick'
    'click .close' : 'close'
  btnClick : (e) ->
    btnCbfs = @btnCbfs
    obj = $ e.currentTarget
    key = obj.text()
    cbf = btnCbfs?[key]
    cbfResult = null
    if _.isFunction cbf
      cbfResult = cbf @$el
    if cbfResult != false
      @close()
    @
  open : ->
    @$el.show()
    @
  close : ->
    if @modalMask
      @modalMask.hide()
    if @model.destroyOnClose
      @destroy()
    else
      @$el.hide()
    @
  destroy : ->
    if @model.modal
      @modalMask.remove()
    @remove()
  getBtnsHtml : (btns) ->
    if !btns
      ''
    else
      btnHtmlArr = []
      _.each btns, (value, key) ->
        btnHtmlArr.push "<a class='btn' href='javascript:;'>#{key}</a>"
      "<div class='btns'>#{btnHtmlArr.join('')}</div>"
  initialize : ->
    self = @
    @$el.addClass 'jtWidget jtDialog jtBorderRadius3'
    @listenTo @model, "all", (event) ->
      if !~event.indexOf ':'
        self.render()
    @render()
    @
  render : ->
    @templateData = @model.toJSON()

    @btnCbfs = @templateData.btns
    @templateData.btns = @getBtnsHtml @templateData.btns
    if @model.modal
      @modalMask = $('<div class="jtMask" />').appendTo 'body'
    html = @template @templateData
    @$el.html html
}

JT.View.Alert = Backbone.View.extend {
  initialize : ->
    el = $('<div class="jtAlertDlg" />').appendTo('body').get 0
    new JT.View.Dialog {
      el : el
      model : @model
    }
}

JT.DatePicker = Backbone.View.extend {
  events : 
    'click .daysContainer .prev' : 'prevMonth'
    'click .daysContainer .next' : 'nextMonth'
    'click .daysContainer .dateView' : 'showMonths'
    'click .daysContainer .day' : 'selectDay'
    'click .monthsContainer .prev' : 'prevYear'
    'click .monthsContainer .next' : 'nextYear'
    'click .monthsContainer .month' : 'selectMonth'
  datePickerHtml : '<div class="jtDatePicker jtBorderRadius3">' +
    '<div class="arrowContainer arrowContainerBottom"></div>' +
    '<div class="arrowContainer"></div>' +
    '<div class="daysContainer">' +
      '<table>' + 
        '<thead></thead>' +
        '<tbody></tbody>' +
      '</table>' +
    '</div>' +
    '<div class="monthsContainer">' +
      '<table>' + 
        '<thead></thead>' +
        '<tbody></tbody>' +
      '</table>' +
    '</div>' +
    '<div class="yearsContainer">' +
      '<table>' + 
        '<thead></thead>' +
        '<tbody></tbody>' +
      '</table>' +
    '</div>' +
  '</div>'
  monthsTheadTemplate : _.template '<tr>' +
    '<th class="prev">‹</th>' +
    '<th colspan="5" class="dateView"><%= year %></th>' + 
    '<th class="next">›</th>' + 
  '</tr>'
  daysTheadTemplate : _.template '<tr>' +
    '<th class="prev">‹</th>' +
    '<th colspan="5" class="dateView"><%= date %></th>' + 
    '<th class="next">›</th>' + 
  '</tr>' + 
  '<tr>' + 
    '<th>Su</th><th>Mo</th><th>Tu</th><th>We</th><th>Th</th><th>Fr</th><th>Sa</th>' +
  '</tr>'
  initialize : ->
    self = @
    $el = @$el
    options = @options
    options.months ?= ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月']
    @date = new Date options.date || new Date()
    elOffset = $el.offset()
    datePicker = $ @datePickerHtml
    datePicker.css {left : elOffset.left, top : elOffset.top + $el.outerHeight(true) + 10}
    datePicker.appendTo 'body'
    @$inputObj = $el
    @setElement datePicker.addClass 'jtWidget'
    @render()
    @$inputObj.on 'click.jtDatePicker', () ->
      if datePicker.is ':hidden'
        self.show()
      else
        self.hide()
    @
  prevMonth : ->
    date = @date
    month = date.getMonth()
    if month > 0
      date.setMonth month - 1
    else
      date.setYear date.getFullYear() - 1
      date.setMonth 11
    @render()
  nextMonth : ->
    date = @date
    month = date.getMonth()
    if month < 11
      date.setMonth month + 1
    else
      date.setYear date.getFullYear() + 1
      date.setMonth 0
    @render()
  prevYear : ->
    date = @date
    @date.setFullYear date.getFullYear() - 1
    @render 'month'
  nextYear : ->
    date = @date
    @date.setFullYear date.getFullYear() + 1
    @render 'month'
  showMonths : ->
    @render 'month'
  selectDay : (e) ->
    obj = $ e.currentTarget
    @date.setDate obj.text()
    @val().hide()
    @
  val : ->
    date = @date
    month = date.getMonth() + 1
    year = date.getFullYear()
    day = date.getDate()
    if month < 10
      month = '0' + month
    if day < 10
      day = '0' + day
    @$inputObj.val "#{year}-#{month}-#{day}"
    @
  selectMonth : (e) ->
    obj = $ e.currentTarget
    @date.setMonth obj.index '.month'
    @val().render 'day'
    @
  # toggle : ->
  #   @$el.toggle()
  #   @
  show : ->
    @render()
    @$el.show()
    @
  hide : ->
    @$el.hide()
    @
  getMonthsTbody : ->
    tbodyHtml = []
    months = @options.months
    tbodyHtml.push '<tr><td colspan="7">'
    _.each months, (month, i) ->
      tbodyHtml.push "<span class='month'>#{month}</span>"
    tbodyHtml.push '</td></tr>'
    tbodyHtml.join ''
  getDaysTbody : ->
    dayTotalList = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    date = new Date @date.getTime()
    date.setDate 1
    index = date.getDay()

    month = date.getMonth()
    year = date.getFullYear()

    if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
      dayTotalList[1] = 29

    dateTotal = dayTotalList[month] + index

    currentDate = new Date()
    currentDayMatchFlag = false
    if currentDate.getMonth() == month && currentDate.getFullYear() == year
      currentDayMatchFlag = true
      currentDay = currentDate.getDate()

    selectDayMatchFlag = false
    if @date.getMonth() == month && @date.getFullYear() == year
      selectDayMatchFlag = true
      selectDay = @date.getDate()

    tbodyHtml = []
    for i in [0...dateTotal]
      if i == 0
        tbodyHtml.push '<tr>'
      else if i % 7 == 0
        tbodyHtml.push '</tr><tr>'
      else if i == dateTotal
        tbodyHtml.push '</tr>'
      if i < index
        tbodyHtml.push "<td></td>"
      else
        day = i - index + 1
        if selectDayMatchFlag && day == selectDay
          tbodyHtml.push "<td class='active jtBorderRadius3 day'>#{day}</td>"
        else if currentDayMatchFlag && day == currentDay
          tbodyHtml.push "<td class='currentDay jtBorderRadius3 day'>#{day}</td>"
        else
          tbodyHtml.push "<td class='day'>#{day}</td>"
    tbodyHtml.join ''
  getViewDate : ->
    months = @options.months
    "#{months[@date.getMonth()]} #{@date.getFullYear()}"
  render : (type = 'day') ->
    datePicker = @$el
    daysContainer = datePicker.find '.daysContainer'
    monthsContainer = datePicker.find '.monthsContainer'
    if type == 'day'
      daysContainer.show()
      monthsContainer.hide()
      daysContainer.find('thead').html @daysTheadTemplate {date : @getViewDate()}
      daysContainer.find('tbody').html @getDaysTbody()
    else if type == 'month'
      daysContainer.hide()
      monthsContainer.show()
      monthsContainer.find('thead').html @monthsTheadTemplate {year : @date.getFullYear()}
      monthsContainer.find('tbody').html @getMonthsTbody()

    @
  destroy : ->
    @$inputObj.off '.jtDatePicker'
    @remove()
}



JT.Model.Accordion = Backbone.Model.extend {}

JT.Collection.Accordion = Backbone.Collection.extend {
  model : JT.Model.Accordion
}


JT.View.Accordion = Backbone.View.extend {
  events : 
    'click .item .title' : 'active'
  itemTemplate : _.template '<div class="item">' +
    '<h3 class="title"><div class="jtArrowDown"></div><div class="jtArrowRight"></div><%= title %></h3>' +
    '<div class="content"><%= content %></div>' +
  '</div>'
  initialize : ->
    self = @
    @$el.addClass 'jtWidget jtAccordion jtBorderRadius3'
    @listenTo @model, "all", (event) ->
      if !~event.indexOf ':'
        index = self.activeIndex
        self.activeIndex = -1
        self.render index
    @render()
    @
  active : (index) ->
    $el = @$el
    if !_.isNumber index
      index = $(index.currentTarget).closest('.item').index()
    if @activeIndex != index
      $el.find('.item').each (i) ->
        obj = $ @
        if i == index
          obj.addClass('active').find('.title').addClass('jtBlueGradient').removeClass 'jtGrayGradient'
        else
          obj.removeClass('active').find('.title').addClass('jtGrayGradient').removeClass 'jtBlueGradient'
      @activeIndex = index
    @
  render : (activeIndex = 0) ->
    self = @
    htmlArr = _.map @model.toJSON(), (item) ->
      self.itemTemplate item
    @$el.html htmlArr.join ''
    @active activeIndex
    @
}


JT.Model.Tabs = Backbone.Model.extend {}

JT.Collection.Tabs = Backbone.Collection.extend {
  model : JT.Model.Tabs
}

JT.View.Tabs = Backbone.View.extend {
  events : 
    'click .nav li' : 'active'
  initialize : ->
    self = @
    @$el.addClass 'jtWidget jtTabs jtBorderRadius3'
    @render()
    @listenTo @model, "all", (event) ->
      if !~event.indexOf ':'
        index = self.activeIndex
        self.activeIndex = -1
        self.render index
    @
  active : (index) ->
    $el = @$el
    if !_.isNumber index
      index = $(index.currentTarget).index()
    if @activeIndex != index
      liList = $el.find '.nav li'
      tabList = $el.find '.tab'
      if @activeIndex?
        liList.eq(@activeIndex).removeClass 'active'
        tabList.eq(@activeIndex).removeClass 'active'
      liList.eq(index).addClass 'active'
      tabList.eq(index).addClass 'active'
      @activeIndex = index
    @
  render : (activeIndex = 0) ->
    self = @
    data = @model.toJSON()
    titleArr = _.pluck data, 'title'
    contentArr = _.pluck data, 'content'
    liHtmlArr = _.map titleArr, (title) ->
      "<li>#{title}</li>"
    tabHtmlArr = _.map contentArr, (content) ->
      "<div class='tab'>#{content}</div>"
    @$el.html "<ul class='jtBlueGradient nav'>#{liHtmlArr.join('')}</ul>#{tabHtmlArr.join('')}"
    @active activeIndex
    @
}
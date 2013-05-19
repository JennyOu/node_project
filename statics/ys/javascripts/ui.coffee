window.JT ?= {}
$ = window.jQuery

JT.Select = Backbone.View.extend {
  template : _.template '<div class="jtSelect grayGradient borderRadius3">' +
    '<a href="javascript:;" class="showSelect icon iArrowDown"></a>' +
    '<input class="userInput" type="text" title="<%= name %>" placeholder="<%= name %>" />' +
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
    @$el.find('.showSelect').removeClass('iArrowDown').addClass 'iArrowUp'
    selectList.show()
    @
  hide : (selectList) ->
    @reset()
    @$el.find('.showSelect').removeClass('iArrowUp').addClass 'iArrowDown'
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
    data = @options.data
    listHtmlArr = _.map data.list, (item) ->
      if _.isObject item
        name = item.name
        key = item.key
      else
        name = item
        key = item
      "<li class='option' data-key='#{key}'>#{name}</li>"
    @templateData = 
      name : data.name
      list : listHtmlArr.join ''
    @render()
    @
  render : ->
    html = @template @templateData
    @$el.html html
    @
}

JT.Dialog = Backbone.View.extend {
  template : _.template '<h3 class="title blueGradient borderRadius3"><a href="javascript:;" class="close icon iRemove iRemoveWhite"></a><%= title %></h3>' +
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
    if @options.destroyOnClose
      @destroy()
    else
      @$el.hide()
    @
  destroy : ->
    @remove()
    @$el.remove()
  getBtnsHtml : (btns) ->
    if !btns
      ''
    else
      btnHtmlArr = []
      _.each btns, (value, key) ->
        btnHtmlArr.push "<a class='btn' href='javascript:;'>#{key}</a>"
      "<div class='btns'>#{btnHtmlArr.join('')}</div>"
  initialize : ->
    options = @options
    @$el.addClass 'jtDialog borderRadius3'
    @templateData = 
      title : options.title || ''
      content : options.content || ''
      btns : @getBtnsHtml options.btns
    @btnCbfs = options.btns
    @render()
    @
  render : ->
    html = @template @templateData
    @$el.html html
}

JT.Alert = Backbone.View.extend {
  initialize : ->
    options = @options
    @$el = $('<div class="jtAlertDlg" />').appendTo 'body'
    options.el = @$el.get 0
    options.destroyOnClose = true
    if !options.btns
      options.btns = 
        '确定' : ->
    new JT.Dialog options
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
  datePickerHtml : '<div class="jtDatePicker borderRadius3">' +
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
    @el = datePicker[0]
    @$el = datePicker
    @datePicker = datePicker
    @render()
    @$inputObj.click () ->
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
          tbodyHtml.push "<td class='active borderRadius3 day'>#{day}</td>"
        else if currentDayMatchFlag && day == currentDay
          tbodyHtml.push "<td class='currentDay borderRadius3 day'>#{day}</td>"
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
}
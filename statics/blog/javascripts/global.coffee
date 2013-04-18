window.TIME_LINE.timeEnd 'loadjs'
window.TIME_LINE.time 'execjs'
jQuery ($) ->
  $.get('/nocacheinfo?cache=false').success (userInfo) ->
  	console.dir userInfo
  window.TIME_LINE.timeEnd 'all', 'html'
  console.dir window.TIME_LINE.getLogs()  
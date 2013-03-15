jQuery ($) ->
  $('.codeContainer').each () ->
    CodeMirror.fromTextArea @, {
      lineNumbers: true
      theme : 'monokai'
      readOnly : true
    }

window.MergeAjax =
  options : []
  cbfs : []
  handler : (option, cbf) ->
    self = @
    self.options.push option
    self.cbfs.push cbf
    setTimeout () ->
      if self.options.length
        resultCbfs = self.cbfs
        opts = 
          data : self.options
        jQuery.ajax {
          type : 'post'
          url : 'mergeajax'
          data : opts
          success : (data) ->
            _.each resultCbfs, (cbf, i) ->
              cbf null, data[i]
          error : () ->

        }
        self.options = []
        self.cbfs = []
    , 0


jQuery ($) ->

  option1 = 
    url : '/test1'

  option2 =
    url : '/test2'
    type : 'post'
    data : 
      pwd : '123456'

  MergeAjax.handler option1, (err, data) ->
    console.dir data

  MergeAjax.handler option2, (err, data) ->
    console.dir data
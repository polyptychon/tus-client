$ = require "jquery" unless jQuery?
$ = jQuery unless $?

class CheckFileExists

  CheckFileExists.DEFAULTS =
    headers: {}

  constructor: (files, options) ->
    @files = files
    @options = $.extend(CheckFileExists.DEFAULTS, options)
    @filenames = []
    for file in files
      @filenames.push(file.name)

    # the jqXHR object
    @_jqXHR = null

    # Create a deferred and make our upload a promise object
    @_deferred = $.Deferred();
    @_deferred.promise(this);

  _checkFiles : ->
    headers = $.extend({}, @options.headers)

    options =
      type:    'POST'
      url:     "#{@options.endpoint}check"
      cache:   false
      contentType: "application/json; charset=UTF-8"
      headers: headers
      processData : false
      data:    JSON.stringify({"filenames":@filenames})

    @_jqXHR = $.ajax(options)
    .fail(
        (jqXHR, textStatus, errorThrown) =>
          @_emitFail(new Error("#{textStatus}: #{errorThrown}"))
      )
    .done(
        (data, textStatus, jqXHR) =>
          console.log(!data.results?)
          if (!data.results?)
            @_emitFail(new Error("Bad Response"))
            return
          foundFiles = []
          foundFilesString = ''
          for file in data.results
            if file.status == 'found'
              foundFiles.push(file)
              foundFilesString += file.name+', '
          foundFilesString = foundFilesString.substr(0, foundFilesString.length-2)

          if foundFiles.length > 0
            @_emitFail({foundFiles:foundFiles, results: data.results, foundFilesString: foundFilesString, status:'found'})
          else
            @_emitDone()

      )

  stop : ->
    @_jqXHR.abort() if @_jqXHR?

  _emitDone : ->
    @_deferred.resolveWith(this, [@files])

  _emitFail : (err, status) ->
    @_deferred.rejectWith(this, [err, status])

module.exports = CheckFileExists

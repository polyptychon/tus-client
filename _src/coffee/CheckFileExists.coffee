$ = require "jquery" unless jQuery?
$ = jQuery unless $?

class CheckFileExists

  CheckFileExists.DEFAULTS =
    path: ""
    headers: {}

  constructor: (file, options) ->
    @file = file
    @options = $.extend(CheckFileExists.DEFAULTS, options)

    # The url of the uploaded file, assigned by the tus upload endpoint
    @fileUrl = null

    # @TODO Add @bytesTotal again

    # the jqXHR object
    @_jqXHR = null

    # Create a deferred and make our upload a promise object
    @_deferred = $.Deferred();
    @_deferred.promise(this);

  _checkFileExists : ->
    headers = $.extend({
      'file-path': "#{@options.path}/#{@file.name}"
    }, @options.headers)

    options =
      type:    'HEAD'
      url:     @options.endpoint
      cache:   false
      headers: headers

    $.ajax(options)
    .fail(
        (jqXHR, textStatus, errorThrown) =>
          if(jqXHR.status == 404)
            @_emitFail("File not found: #{textStatus}", jqXHR.status)
          else
            @_emitFail(textStatus, jqXHR.status)
      )
    .done(
        (data, textStatus, jqXHR) =>
          @_emitDone()
      )

  stop : ->
    @_jqXHR.abort() if @_jqXHR?

  _emitDone : ->
    @_deferred.resolveWith(this, [@fileUrl, @file])

  _emitFail : (err, status) ->
    @_deferred.rejectWith(this, [err, status])

module.exports = CheckFileExists

$ = require "jquery" unless jQuery?
$ = jQuery unless $?
ResumableUpload = require "./ResumableUpload.coffee"

class PolyResumableUpload extends ResumableUpload

  PolyResumableUpload.DEFAULTS =
    moveFileAfterUpload: false
    chunkSize: null
    minChunkSize: 51200
    maxChunkSize: 2097152
    path: ""

  constructor: (file, options) ->
    options = $.extend(PolyResumableUpload.DEFAULTS, options)

    @_chunkTimer = -1

    super(file, options)

  _getChunkSize : ->
    if (@_chunkTimer < 0)
      chunkSize = @options.minChunkSize
    else
      diff = (new Date().getTime()) - @_chunkTimer
      chunkSize = Math.round(@options.chunkSize / diff * 1000)

    @_chunkTimer = new Date().getTime()

    return Math.min(Math.max(@options.minChunkSize, chunkSize), @options.maxChunkSize)

  _uploadFile : (range_from) ->
    if (@options.chunkSize)
      @options.chunkSize = @_getChunkSize()

    super(range_from)

  _emitDone : ->
    if (@options.moveFileAfterUpload)
      @_moveFile()
    else
      @_deferred.resolveWith(this, [@fileUrl, @file, null])

  _moveDone : (md5)->
    @_deferred.resolveWith(this, [@fileUrl, @file, md5])

  _moveFile : ->
    headers = $.extend({}, @options.headers)

    options =
      type:    'POST'
      url:     "#{@fileUrl}/move"
      cache:   false
      contentType: "application/json; charset=UTF-8"
      data:    JSON.stringify({ path: (@options.path+@file.name)})
      headers: headers
    
    @_jqXHR = $.ajax(options)
      .fail(
        (jqXHR, textStatus, errorThrown) =>
          if(jqXHR.status == 404)
            @_emitFail("Could not head at file resource: #{textStatus}", jqXHR.status)
          else
            @_emitFail("Could not move file resource: #{errorThrown} #{textStatus}", jqXHR.status)
      )
      .done(
        (data, textStatus, jqXHR) =>
          checksum = jqXHR.getResponseHeader('Checksum')
          location = jqXHR.getResponseHeader('Location')
          return @_emitFail('Could not get url for file resource. ' + textStatus, jqXHR.status) unless location
          @fileUrl = location
          @_moveDone(checksum)
      )

module.exports = PolyResumableUpload

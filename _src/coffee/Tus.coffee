$ = require "jquery"

module.exports = {
  upload: (file, options) ->
    upload = new PolyResumableUpload(file, options)
    upload._start() if (file)
    return upload
  check: (file, options) ->
    check = new CheckFileExists(file, options)
    check._checkFileExists() if (file)
    return check
}

class PolyResumableUpload extends ResumableUpload

  PolyResumableUpload.DEFAULTS =
    chunkSize: 1
    minChunkSize: 51200
    maxChunkSize: 2097152*100
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
    @_moveFile()

  _moveDone : (md5)->
    @_deferred.resolveWith(this, [@fileUrl, @file, md5])

  _moveFile : ->
    headers = $.extend({
      'Final-Length': @file.size
      'file-path': "#{@options.path}/#{@file.name}"
    }, @options.headers)

    options =
      type:    'PUT'
      url:     @fileUrl
      cache:   false
      headers: headers

    $.ajax(options)
    .fail(
        (jqXHR, textStatus, errorThrown) =>
          if(jqXHR.status == 404)
            @_emitFail("Could not move file resource: #{textStatus}", jqXHR.status)
          else
            @_emitFail("Could not head at file resource: #{textStatus}", jqXHR.status)
      )
    .done(
        (data, textStatus, jqXHR) =>
          checksum = jqXHR.getResponseHeader('Checksum')
          location = jqXHR.getResponseHeader('Location')
          return _emitFail('Could not get url for file resource. ' + textStatus, jqXHR.status) unless location
          @fileUrl = location
          @_moveDone(checksum)
      )


class ResumableUpload

  ResumableUpload.SUPPORT = ->
    ((typeof(File) != 'undefined') && (typeof(Blob) != 'undefined') &&
    (typeof(FileList)!= 'undefined') &&
    (!!Blob.prototype.webkitSlice || !!Blob.prototype.mozSlice || !!Blob.prototype.slice || false)
    )

  ResumableUpload.DEFAULTS =
    resumable: true
    headers:   {}

  constructor: (file, options) ->
    @file = file

    @options = $.extend(ResumableUpload.DEFAULTS, options)

    # The url of the uploaded file, assigned by the tus upload endpoint
    @fileUrl = null

    # Bytes sent to the server so far
    @bytesWritten = null

    # @TODO Add @bytesTotal again

    # the jqXHR object
    @_jqXHR = null

    # Create a deferred and make our upload a promise object
    @_deferred = $.Deferred();
    @_deferred.promise(this);

  _start : ->
    # Optionally resetBefore
    @_urlCache false  if not @options.resumable or @options.resetBefore is true
    unless @fileUrl = @_urlCache()
      @_post()
    else
      @_head()

  _post : ->
    headers = $.extend({
      'Final-Length': @file.size
    }, @options.headers)

    options =
      type:    'POST'
      url:     @options.endpoint
      headers: headers

    $.ajax(options)
    .fail(
        (jqXHR, textStatus, errorThrown) =>
          # @todo: Implement retry support
          @_emitFail("Could not post to file resource #{@options.endpoint}. #{textStatus}", jqXHR.status)
      )
    .done(
        (data, textStatus, jqXHR) =>
          location = jqXHR.getResponseHeader('Location')
          return _emitFail('Could not get url for file resource. ' + textStatus, jqXHR.status) unless location
          @fileUrl = location
          @_uploadFile(0)
      )

  _head : ->
    options =
      type:    'HEAD'
      url:     @fileUrl
      cache:   false
      headers: @options.headers

    $.ajax(options)
    .fail(
        (jqXHR, textStatus, errorThrown) =>
          if(jqXHR.status == 404)
            @_post()
          else
            @_emitFail("Could not head at file resource: #{textStatus}", jqXHR.status);
      )
    .done(
        (data, textStatus, jqXHR) =>
          offset = jqXHR.getResponseHeader('Offset');
          bytesWritten = if parseInt(offset, 10) then parseInt(offset) else 0
          @_uploadFile(bytesWritten);
      )

  _uploadFile : (range_from) ->
    @bytesWritten = range_from
    if (@bytesWritten == @file.size)
      # Cool, we already completely uploaded this.
      # Update progress to 100%.
      @_emitProgress()
      return @_emitDone()

    @_urlCache(@fileUrl)
    @_emitProgress()

    bytesWrittenAtStart = @bytesWritten

    range_to = @file.size

    if(@options.chunkSize)
      range_to = Math.min(range_to, range_from + @options.chunkSize)

    slice = @file.slice || @file.webkitSlice || @file.mozSlice
    blob  = slice.call(@file, range_from, range_to, @file.type)
    xhr   = $.ajaxSettings.xhr()

    headers = $.extend({
      'Offset': range_from
      'Content-Type': 'application/offset+octet-stream'
    }, @options.headers)

    options =
      type:         'PATCH'
      url:          @fileUrl
      data:         blob
      processData:  false
      contentType:  @file.type
      cache:        false
      headers:      headers
      xhr: ->       return xhr

    $(xhr.upload).bind('progress',
    (e) =>
      @bytesWritten = bytesWrittenAtStart + e.originalEvent.loaded
      @_emitProgress(e)
    )

    @_jqXHR = $.ajax(options)
    .fail(
        (jqXHR, textStatus, errorThrown) =>
          # @TODO: Compile somewhat meaningful error
          # Needs to be cleaned up
          # Needs to have retry
          msg = jqXHR.responseText || textStatus || errorThrown
          @_emitFail(msg, jqXHR.status)
      )
    .done(
        =>
          if(range_to == @file.size)
            @_urlCache(false) if @options.resetAfter
            @_emitDone()
          else
            # still have more to upload
            @_uploadFile(range_to)
      )

  stop : ->
    @_jqXHR.abort() if @_jqXHR?

  _emitProgress : (e = null) ->
    @_deferred.notifyWith(this, [e, @bytesWritten, @file.size])

  _emitDone : ->
    @_deferred.resolveWith(this, [@fileUrl, @file])

  _emitFail : (err, status) ->
    @_deferred.rejectWith(this, [err, status])

  _urlCache : (url)->
    fingerPrint = @options.fingerprint;
    fingerPrint ?= @fingerprint(@file);

    if (url == false)
      return localStorage.removeItem(fingerPrint)

    if (url)
      result = false;
      try
        result = localStorage.setItem(fingerPrint, url);
      catch e
      # most likely quota exceeded error

      return result;

    return localStorage.getItem(fingerPrint);

  fingerprint: (file) ->
    'tus-' + file.name + '-' + file.type + '-' + file.size;

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
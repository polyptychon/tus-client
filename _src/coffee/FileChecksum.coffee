$ = require "jquery"
SparkMD5 = require "spark-md5"

class FileChecksum

  FileChecksum.DEFAULTS =
    minChunkSize: 2097152
    chunkSize: 2097152

  constructor: (file, options) ->
    @file = file
    options.minChunkSize = @options.minChunkSize if (options.minChunkSize < @options.minChunkSize)
    @options = $.extend(FileChecksum.DEFAULTS, options)
    @options.chunkSize = @options.minChunkSize if (@options.chunkSize < @options.minChunkSize)
    @spark = new SparkMD5();
    @fileReader = new FileReader()
    @fileReader.onload = (e) =>
      @spark.appendBinary(e.target.result)
      @_emitProgress()
      @_computeChecksum(@range_to)

    @fileReader.onerror = (e) =>
      @_emitFail(e)

    # Create a deferred and make our upload a promise object
    @_deferred = $.Deferred();
    @_deferred.promise(this);

  _computeChecksum : (range_from) ->
    @bytesWritten = range_from

    if (@bytesWritten == @file.size)
      @clientChecksum = @spark.end()
      @_emitDone()
      return

    range_to = @file.size
    chunkSize = @options.chunkSize
    @range_to = Math.min(range_to, range_from + chunkSize)

    slice = @file.slice || @file.webkitSlice || @file.mozSlice
    blob  = slice.call(@file, range_from, @range_to, @file.type)
    @fileReader.readAsBinaryString(blob)


  stop : ->
    @bytesWritten = @file.size
    @spark.end()
    @_emitFail("FileChecksum stopped!")

  _emitProgress : (e = null) ->
    @_deferred.notifyWith(this, [e, @bytesWritten, @file.size])

  _emitDone : ->
    @_deferred.resolveWith(this, [@file, @clientChecksum])

  _emitFail : (err) ->
    @_deferred.rejectWith(this, [err])

module.exports = FileChecksum

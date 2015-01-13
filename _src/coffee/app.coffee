$ = require "jquery"
ResumableUpload = require "./ResumableUpload.coffee"
tus = require "./Tus.coffee"
Q = require "q"

$ ->
  upload = null
  $('.js-stop').click( (e) ->
    e.preventDefault()
    upload.stop() if (upload)
  )

  $('input[type=file]').change( ->
    $input  = $(this)
    $parent = $input.parent()
    file    = this.files[0]

    $('.js-stop').removeClass('disabled')
    $('.progress').addClass('active')

    options =
      endpoint: 'http://localhost:1080/files/'
      resetBefore: $('#reset_before').prop('checked') # if resetBefore is true file always uploads from first byte
      resetAfter: true # clear localStorage after upload completes successfully
#      chunkSize: 1 # if chunkSize is not null then file uploads in chunks
#      minChunkSize: 51200
#      maxChunkSize: 2097152
#      path: "" # Where we want to put uploaded file on server

    openDialogIfFileExist = (error)->
      if (confirm("Do you want to overwrite file #{file.name}?"))
        true
      else
        Q.reject(error)
    doChecksum = ()->
      return tus.checksum(file, options) if $('#checksum').prop('checked')
    startUpload = (result)->
      options.clientChecksum = result.md5 if $('#checksum').prop('checked')
      return tus.upload(file, options)
    displayUploadedFile = (result)->
      $download = $("<a>Download #{file.name} (#{file.size} bytes #{result.md5})</a><br />").appendTo($parent)
      $download.attr('href', result.url)
      $download.addClass('btn').addClass('btn-success')
    updateProgress = (result)->
      console.log(result.percentage)
      upload = result.action
      $('.progress-bar').css('width', "#{result.percentage}%")
    logErrors = (error) ->
      console.log(error)
    resetUI = () ->
      $('.js-stop').addClass('disabled')

    tus.check(file, options)
      .catch(openDialogIfFileExist)
      .then(doChecksum)
      .then(startUpload)
      .then(displayUploadedFile)
      .progress(updateProgress)
      .catch(logErrors)
      .fin(resetUI)
  )

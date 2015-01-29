$ = require "jquery" unless jQuery?
Q = require "q" unless Q?
tus =  require "./Tus.coffee"

$ = jQuery unless $?
upload = null
files = null

$('.js-stop').click( (e) ->
  e.preventDefault()
  tus.stopAll(files) if files
)

$('input[type=file]').change( ->
  $input  = $(this)
  files   = this.files

  $('.js-stop').removeClass('disabled')
  $('.progress').addClass('active')

  options =
    endpoint: 'http://localhost:1080/files/'
    resetBefore: $('#reset_before').prop('checked') # if resetBefore is true file always uploads from first byte
    resetAfter: true # clear localStorage after upload completes successfully
    chunkSize: 1 # if chunkSize is not null then file uploads in chunks
    checksum: true
    minChunkSize: 51200
    maxChunkSize: 2097152
    moveFileAfterUpload: true
    path: "" # Where we want to put uploaded file on server

  openDialogIfFileExist = (error)->
    if (error instanceof Error)
      Q.reject(error)
    else
      Q.reject(error) unless (confirm("File(s) \"#{error.foundFilesString}\" are on server. Do you want to overwrite them?"))
  doChecksum = ()->
    return tus.checksumAll(files, options) if $('#checksum').prop('checked')
  startUpload = ()->
    return tus.uploadAll(files, options)
  displayUploadedFiles = (result)->
    for file in files
      $download = $("<a>Download #{file.name} (#{file.size} bytes #{file.md5})</a><br />").appendTo($(".container"))
      $download.attr('href', file.url)
      $download.addClass('btn').addClass('btn-success')
  updateProgress = (result)->
    $('.progress-bar').css('width', "#{result.value.percentage}%")
  logErrors = (error) ->
    console.log(error)
  resetUI = () ->
    files = null
    $input.wrap('<form>').closest('form').get(0).reset()
    $input.unwrap()
    $('.progress').removeClass('active')
    $('.js-stop').addClass('disabled')

  tus.checkAll(files, options)
    .catch(openDialogIfFileExist)
    .then(doChecksum)
    .then(startUpload)
    .then(displayUploadedFiles)
    .progress(updateProgress)
    .catch(logErrors)
    .fin(resetUI)

#  options =
#    endpoint: 'http://localhost:1080/files/'
#    resetBefore: $('#reset_before').prop('checked') # if resetBefore is true file always uploads from first byte
#    resetAfter: true # clear localStorage after upload completes successfully
#    chunkSize: 2097152 # if chunkSize is not null then file uploads in chunks
#    moveFileAfterUpload: false
#
#  tus.uploadAll(files, options)
#    .then(displayUploadedFiles)
#    .progress(updateProgress)
#    .catch(logErrors)
#    .fin(resetUI)
)

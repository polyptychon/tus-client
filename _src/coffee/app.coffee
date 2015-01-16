$ = require "jquery" unless jQuery?
Q = require "q" unless Q?
ResumableUpload = require "./ResumableUpload"
tus =  require "./Tus"

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
  overwriteMessage = "Some files are on server. Do you want to overwrite them?"

  $('.js-stop').removeClass('disabled')
  $('.progress').addClass('active')

  options =
    endpoint: 'http://localhost:1080/files/'
    resetBefore: $('#reset_before').prop('checked') # if resetBefore is true file always uploads from first byte
    resetAfter: true # clear localStorage after upload completes successfully
    chunkSize: 1 # if chunkSize is not null then file uploads in chunks
    minChunkSize: 51200
    maxChunkSize: 2097152
    path: "" # Where we want to put uploaded file on server

  openDialogIfFileExist = (error)->
    Q.reject(error) unless (confirm(overwriteMessage))
  doChecksum = ()->
    return tus.checksumAll(files, options) if $('#checksum').prop('checked')
  startUpload = ()->
    return tus.uploadAll(files, options)
  displayUploadedFiles = (result)->
    for file in files
      $download = $("<a>Download #{file.name} (#{file.size} bytes #{file.md5})</a><br />").appendTo($(".container"))
      $download.attr('href', result.url)
      $download.addClass('btn').addClass('btn-success')
  updateProgress = (percentage)->
    $('.progress-bar').css('width', "#{percentage}%")
  logErrors = (error) ->
    console.log(error)
  resetUI = () ->
    files = null
    $input.wrap('<form>').closest('form').get(0).reset();
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
)

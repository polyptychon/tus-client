$ = require "jquery"
ResumableUpload = require "./ResumableUpload.coffee"
tusCheck = require "./TusCheck.coffee"
tus = require "./Tus.coffee"

$ ->
  unless ResumableUpload.SUPPORT
    console.log "Upload is not supported"
    return

  upload = null

  $('.js-stop').click( (e) ->
    e.preventDefault()
    upload.stop() if (upload)
  )

  $('input[type=file]').change( ->
    $input  = $(this)
    $parent = $input.parent()
    file    = this.files[0]

    #console.log('selected file', file)
    $('.js-stop').removeClass('disabled')

    options =
      endpoint: 'http://localhost:1080/files/'
      resetBefore: $('#reset_before').prop('checked')
      resetAfter: false

    $('.progress').addClass('active')

    tusCheck.check(file, options)
      .fail((error, status) ->
        startUpload()
      )
      .done((url, file) ->
        if (confirm("Do you want to overwrite file #{file.name}?"))
          startUpload()
      )

    startUpload = ->
      upload = tus.upload(file, options)
        .fail( (error, status) ->
          alert("Failed because: #{error}. Status: #{status}")
        )
        .always( ->
          $input.val('')
          $('.js-stop').addClass('disabled')
          $('.progress').removeClass('active')
        )
        .progress((e, bytesUploaded, bytesTotal) ->
          percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
          $('.progress-bar').css('width', "#{percentage}%");
          #console.log(bytesUploaded, bytesTotal, "#{percentage}%");
        )
        .done((url, file, md5) ->
          $download = $("<a>Download #{file.name} (#{file.size} bytes #{md5})</a><br />").appendTo($parent)
          $download.attr('href', url)
          $download.addClass('btn').addClass('btn-success')
        )
  )
$ = require "jquery"
ResumableUpload = require "./ResumableUpload.coffee"
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
      resetAfter: true

    $('.progress').addClass('active')

    tus.check(file, options)
      .fail((error, status) ->
        if $('#checksum').prop('checked')
          getChecksum()
        else
          startUpload()
      )
      .done((url, file) ->
        if (confirm("Do you want to overwrite file #{file.name}?"))
          if $('#checksum').prop('checked')
            getChecksum()
          else
            startUpload()
      )

    getChecksum = ->
      tus.checksum(file, options)
        .progress((e, bytesUploaded, bytesTotal) ->
          percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
          $('.progress-bar').css('width', "#{percentage}%");
        )
        .done((file, md5) ->
          options.clientChecksum = md5
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
        )
        .done((url, file, md5) ->
          if (options.clientChecksum==md5)
            console.log("File checksum is ok.\nServer Checksum: #{md5} = Client: #{options.clientChecksum}")
          else
            console.log("File checksum error.\nServer Checksum: #{md5} = Client: #{options.clientChecksum}")

          $download = $("<a>Download #{file.name} (#{file.size} bytes #{md5})</a><br />").appendTo($parent)
          $download.attr('href', url)
          $download.addClass('btn').addClass('btn-success')
        )
  )
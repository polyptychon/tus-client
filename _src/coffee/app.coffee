$ = require "jquery"
ResumableUpload = require "./ResumableUpload.coffee"
tus = require "./Tus.coffee"

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

    options =
      endpoint: 'http://localhost:1080/files/'
      resetBefore: $('#reset_before').prop('checked')
      resetAfter: true

    $('.progress').addClass('active')

    tus.check(file, options)
      .then((result)->
        return tus.checksum(file, options) if $('#checksum').prop('checked')
      )
      .then((result)->
        return tus.upload(file, options)
      )
      .then((result)->
        $download = $("<a>Download #{file.name} (#{file.size} bytes #{result.md5})</a><br />").appendTo($parent)
        $download.attr('href', result.url)
        $download.addClass('btn').addClass('btn-success')
      )
      .progress((percentage)->
        $('.progress-bar').css('width', "#{percentage}%")
      )
      .catch((error)->
        console.log(error);
      )

#    tus.check(file, options)
#      .fail((error, status) ->
#        upload()
#      )
#      .done((url, file) ->
#        if (confirm("Do you want to overwrite file #{file.name}?"))
#          upload()
#      )
#    upload = ->
#      if $('#checksum').prop('checked')
#        getChecksum()
#      else
#        options.clientChecksum = null
#        startUpload()
#
#    getChecksum = ->
#      tus.checksum(file, options)
#        .progress((e, bytesUploaded, bytesTotal) ->
#          percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
#          $('.progress-bar').css('width', "#{percentage}%");
#        )
#        .done((file, md5) ->
#          options.clientChecksum = md5
#          startUpload()
#        )
#
#    startUpload = ->
#      upload = tus.upload(file, options)
#        .fail( (error, status) ->
#          alert("Failed because: #{error}. Status: #{status}")
#        )
#        .always( ->
#          $input.val('')
#          $('.js-stop').addClass('disabled')
#          $('.progress').removeClass('active')
#        )
#        .progress((e, bytesUploaded, bytesTotal) ->
#          percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
#          $('.progress-bar').css('width', "#{percentage}%");
#        )
#        .done((url, file, md5) ->
#          if (options.clientChecksum)
#            if (options.clientChecksum==md5)
#              console.log("File checksum is ok.\nServer Checksum: #{md5} = Client: #{options.clientChecksum}")
#            else
#              console.log("File checksum error.\nServer Checksum: #{md5} = Client: #{options.clientChecksum}")
#
#          $download = $("<a>Download #{file.name} (#{file.size} bytes #{md5})</a><br />").appendTo($parent)
#          $download.attr('href', url)
#          $download.addClass('btn').addClass('btn-success')
#        )
  )

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
        options.clientChecksum = result.md5 if $('#checksum').prop('checked')
        return tus.upload(file, options)
      )
      .then((result)->
        $download = $("<a>Download #{file.name} (#{file.size} bytes #{result.md5})</a><br />").appendTo($parent)
        $download.attr('href', result.url)
        $download.addClass('btn').addClass('btn-success')
      )
      .progress((result)->
        console.log(result.percentage)
        upload = result.action
        $('.progress-bar').css('width', "#{result.percentage}%")
      )
      .catch((error)->
        console.log(error)
      )
      .fin(()->
        $('.js-stop').addClass('disabled')
      )
  )

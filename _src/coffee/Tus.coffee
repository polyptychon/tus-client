$ = require "jquery" unless jQuery?
$ = jQuery unless $?
Q = require "q" unless global.Q?
Q = global.Q if global.Q?
ResumableUpload = require "./ResumableUpload"
PolyResumableUpload = require "./PolyResumableUpload"
CheckFileExists = require "./CheckFileExists"
FileChecksum = require "./FileChecksum"

global.gr = global.gr || {}
global.gr.polyptychon = global.gr.polyptychon || {}

global.gr.polyptychon.tus = {
  upload: (file, options) ->
    deferred = Q.defer()
    upload = new PolyResumableUpload(file, options)
    file.stoppableAction = upload
    upload.fail( (error, status) ->
      file.stoppableAction = null
      deferred.reject(new Error({error: error, status: status}))
    )
    upload.progress((e, bytesUploaded, bytesTotal) ->
      percentage = (bytesUploaded / bytesTotal * 100).toFixed(2)
      file.percentage = percentage
      deferred.notify({percentage:percentage, file:file, options: options})
    )
    upload.done((url, file, md5) ->
      file.stoppableAction = null
      file.percentage = null
      if (file.md5 && md5)
        if (file.md5==md5)
          deferred.resolve({url: url, md5: md5, file: file, options: options})
        else
          deferred.reject(new Error("Checksum does not match. #{file.md5} != #{md5}"))
      else
        file.md5 = md5 if md5
        file.url = url if url
        deferred.resolve({url: url, md5: md5, file: file, options: options})
    )
    upload._start() if (file)
    return deferred.promise

  check: (file, options) ->
    deferred = Q.defer()
    check = new CheckFileExists(file, options)
    file.stoppableAction = check
    check._checkFileExists() if (file)
    check.fail((error, status) ->
      deferred.resolve({file: file, options: options});
    )
    .done((url, file) ->
      deferred.reject({message:"File already exist", file:file, options: options });
    )
    return deferred.promise

  checksum: (file, options) ->
    deferred = Q.defer()
    checksum = new FileChecksum(file, options)
    file.stoppableAction = checksum
    checksum.fail( (error) ->
      file.stoppableAction = null
      deferred.reject(new Error(error))
    )
    checksum.progress((e, bytesUploaded, bytesTotal) ->
      percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
      file.percentage = percentage
      deferred.notify({percentage:percentage, file:file, options: options})
    )
    checksum.done((file, md5) ->
      file.stoppableAction = null
      file.percentage = null
      file.md5 = md5
      deferred.resolve({md5: md5, file: file, options: options})
    )
    checksum._computeChecksum(0) if (file)
    return deferred.promise

  stop: (file)->
    file.stoppableAction.stop() if (file.stoppableAction)
    Q.reject("stop")

  checkAll: (files, options) ->
    promises = []
    promises.push(@check(file, options)) for file in files
    return Q.all(promises)

  checksumAll: (files, options) ->
    promises = []
    promises.push(@checksum(file, options)) for file in files
    return Q.all(promises)

  uploadAll: (files, options) ->
    promises = []
    promises.push(@upload(file, options)) for file in files
    return Q.all(promises)

  stopAll: (files)->
    @stop(file) for file in files
    Q.reject("stop")

  UploadSupport: ResumableUpload.SUPPORT
}

module.exports = global.gr.polyptychon.tus;

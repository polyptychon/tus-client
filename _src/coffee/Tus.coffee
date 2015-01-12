$ = require "jquery"
Q = require "q"
ResumableUpload = require "./ResumableUpload"
PolyResumableUpload = require "./PolyResumableUpload"
CheckFileExists = require "./CheckFileExists"
FileChecksum = require "./FileChecksum"

module.exports = {
  upload: (file, options) ->
    deferred = Q.defer()
    upload = new PolyResumableUpload(file, options)
    upload.fail( (error, status) ->
      deferred.reject(new Error({error: error, status: status}))
    )
    upload.progress((e, bytesUploaded, bytesTotal) ->
      percentage = (bytesUploaded / bytesTotal * 100).toFixed(2)
      deferred.notify(percentage)
    )
    upload.done((url, file, md5) ->
      if (options.clientChecksum)
        if (options.clientChecksum==md5)
          deferred.resolve({url: url, file: file, md5: md5})
        else
          deferred.reject(new Error("Checksum does not match"))
      else
        deferred.resolve({url: url, file: file, md5: md5})
    )
    upload._start() if (file)
    return deferred.promise

  check: (file, options) ->
    deferred = Q.defer();
    check = new CheckFileExists(file, options)
    check._checkFileExists() if (file)
    check.fail((error, status) ->
      deferred.resolve(file);
    )
    .done((url, file) ->
      deferred.reject(new Error("File already exist"));
    )
    return deferred.promise

  checksum: (file, options) ->
    deferred = Q.defer();
    checksum = new FileChecksum(file, options)
    checksum.progress((e, bytesUploaded, bytesTotal) ->
      percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
      deferred.notify(percentage)
    )
    checksum.done((file, md5) ->
      deferred.resolve({file: file, md5: md5});
    )
    checksum._computeChecksum(0) if (file)
    return deferred.promise
  UploadSupport: ResumableUpload.SUPPORT
}
